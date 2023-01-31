#MIT License

#Copyright (c) 2022 Qumulo, Inc.

#Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal 
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions =

#The above copyright notice and this permission notice shall be included in all 
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
#SOFTWARE.

data "aws_iam_policy" "ssmrole" {
  arn = "arn:${var.aws_partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

locals {
  all_nodes = aws_instance.node.*

  kms_arn = var.kms_key_id == null ? "arn:${var.aws_partition}:kms:${var.aws_region}:${var.aws_account_id}:alias/aws/ebs" : "arn:${var.aws_partition}:kms:${var.aws_region}:${var.aws_account_id}:key/${var.kms_key_id}"

  device_names = [
    "/dev/xvdb",
    "/dev/xvdc",
    "/dev/xvdd",
    "/dev/xvde",
    "/dev/xvdf",
    "/dev/xvdg",
    "/dev/xvdh",
    "/dev/xvdi",
    "/dev/xvdj",
    "/dev/xvdk",
    "/dev/xvdl",
    "/dev/xvdm",
    "/dev/xvdn",
    "/dev/xvdo",
    "/dev/xvdp",
    "/dev/xvdq",
    "/dev/xvdr",
    "/dev/xvds",
    "/dev/xvdt",
    "/dev/xvdu",
    "/dev/xvdv",
    "/dev/xvdw",
    "/dev/xvdx",
    "/dev/xvdy",
    "/dev/xvdz",
  ]

  flash_tput             = var.flash_tput > 250 ? var.flash_tput : 250
  disk_config_flash_iops = lookup(var.disk_map[var.disk_config], "workingIOPs")
  flash_iops             = var.flash_iops > local.disk_config_flash_iops ? var.flash_iops : local.disk_config_flash_iops

  working_ebs_block_devices = [
    for i in range(lookup(var.disk_map[var.disk_config], "workingSlots")) : {
      device_name = local.device_names[i]
      volume_type = var.flash_type
      volume_size = lookup(var.disk_map[var.disk_config], "workingSize")
      volume_tput = var.flash_type == "gp2" ? null : local.flash_tput
      volume_iops = var.flash_type == "gp2" ? null : local.flash_iops
    }
  ]

  backing_ebs_block_devices = [
    for i in range(lookup(var.disk_map[var.disk_config], "backingSlots")) : {
      device_name = local.device_names[i + lookup(var.disk_map[var.disk_config], "workingSlots")]
      volume_type = lookup(var.disk_map[var.disk_config], "backingType")
      volume_size = lookup(var.disk_map[var.disk_config], "backingSize")
      volume_tput = null
      volume_iops = null
    }
  ]

  ebs_block_devices = concat(
    local.working_ebs_block_devices,
    local.backing_ebs_block_devices
  )


  working_slot_spec = [
    for i in range(lookup(var.disk_map[var.disk_config], "workingSlots")) : {
      drive_bay = local.device_names[i]
      disk_role = "working"
      disk_size = lookup(var.disk_map[var.disk_config], "workingSize") * 1024 * 1024 * 1024
    }
  ]

  backing_slot_spec = [
    for i in range(lookup(var.disk_map[var.disk_config], "backingSlots")) : {
      drive_bay = local.device_names[i + lookup(var.disk_map[var.disk_config], "workingSlots")]
      disk_role = "backing"
      disk_size = lookup(var.disk_map[var.disk_config], "backingSize") * 1024 * 1024 * 1024
    }
  ]

  slot_specs = concat(local.working_slot_spec, local.backing_slot_spec)
  user_data_spec_info = length(local.slot_specs) == 0 ? {} : {
    spec_info = {
      slot_specs = local.slot_specs
    }
  }

  ingress_rules = [
    {
      port        = 21
      description = "TCP ports for FTP"
      protocol    = "tcp"
    },
    {
      port        = 22
      description = "TCP ports for SSH"
      protocol    = "tcp"
    },
    {
      port        = 80
      description = "TCP ports for HTTP"
      protocol    = "tcp"
    },
    {
      port        = 111
      description = "TCP ports for SUNRPC"
      protocol    = "tcp"
    },
    {
      port        = 443
      description = "TCP ports for HTTPS"
      protocol    = "tcp"
    },
    {
      port        = 445
      description = "TCP ports for SMB"
      protocol    = "tcp"
    },
    {
      port        = 2049
      description = "TCP ports for NFS"
      protocol    = "tcp"
    },
    {
      port        = 3712
      description = "TCP ports for Replication"
      protocol    = "tcp"
    },
    {
      port        = 8000
      description = "TCP ports for REST"
      protocol    = "tcp"
    },
    {
      port        = 111
      description = "UDP port for SUNRPC"
      protocol    = "udp"
    },
    {
      port        = 9000
      description = "TCP port for S3"
      protocol    = "tcp"
    },
    {
      port        = 2049
      description = "UDP port for NFS"
      protocol    = "udp"
    }
  ]
}

resource "aws_security_group" "cluster" {
  name        = "${var.deployment_unique_name}-qumulo-cluster"
  description = "Enable ports for NFS/SMB/FTP/SSH, Management, Replication, and Clustering."
  vpc_id      = var.aws_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Qumulo Internode Communication"
    from_port   = 0
    protocol    = -1
    to_port     = 0
    self        = true
  }

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      cidr_blocks = var.cluster_sg_cidrs
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
    }
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_iam_role" "q_access" {
  name = "${var.deployment_unique_name}-qumulo-cluster"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Sid": ""
    }
  ]
}
EOF

  permissions_boundary = var.permissions_boundary == null ? null : "arn:${var.aws_partition}:iam::${var.aws_account_id}:policy/${var.permissions_boundary}"
}

resource "aws_iam_instance_profile" "q_access" {
  name = "${var.deployment_unique_name}-qumulo-cluster"
  role = aws_iam_role.q_access.name
}

resource "aws_iam_role_policy_attachment" "ssmrole" {
  role       = aws_iam_role.q_access.name
  policy_arn = data.aws_iam_policy.ssmrole.arn
}

resource "aws_iam_role_policy" "policy1" {
  name   = "EC2-CW-logs-policy"
  role   = aws_iam_role.q_access.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:DeleteAlarms",
        "cloudwatch:PutMetricAlarm",
        "ec2:AssignPrivateIpAddresses",
        "ec2:DescribeInstances",
        "ec2:UnassignPrivateIpAddresses",
        "kms:Decrypt",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy2" {
  name   = "KMS-CMK-policy"
  role   = aws_iam_role.q_access.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",        
      "Action": [
        "kms:CreateGrant",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKeyWithoutPlaintext",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo"
      ],
      "Resource": "${local.kms_arn}"
    }
  ]
}
EOF
}

resource "aws_placement_group" "cluster" {
  name     = var.deployment_unique_name
  strategy = var.aws_number_azs == 1 ? "cluster" : "spread"

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_network_interface" "node" {
  count = var.node_count

  private_ips_count = var.floating_ips_per_node
  security_groups   = var.cluster_additional_sg_ids == [] ? [aws_security_group.cluster.id] : concat([aws_security_group.cluster.id], var.cluster_additional_sg_ids)
  subnet_id         = var.private_subnet_ids[count.index]

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}-node ${count.index + 1}" })
}

resource "aws_instance" "node" {
  count = var.node_count

  ami                     = var.ami_id
  disable_api_termination = var.term_protection
  ebs_optimized           = true
  instance_type           = var.instance_type
  key_name                = var.ec2_key_pair
  placement_group         = aws_placement_group.cluster.id
  iam_instance_profile    = aws_iam_instance_profile.q_access.name
  user_data               = length(local.slot_specs) > 0 ? jsonencode(local.user_data_spec_info) : null

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}-node${count.index + 1}" })

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.node[count.index].id
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = var.kms_key_id == null ? "" : "arn:${var.aws_partition}:kms:${var.aws_region}:${var.aws_account_id}:key/${var.kms_key_id}"
    volume_type = var.flash_type

    tags = merge(var.tags, { Name = "${var.deployment_unique_name}-boot" })
  }

  dynamic "ebs_block_device" {
    for_each = local.ebs_block_devices
    content {
      device_name = ebs_block_device.value.device_name
      encrypted   = true
      kms_key_id  = var.kms_key_id == null ? "" : "arn:${var.aws_partition}:kms:${var.aws_region}:${var.aws_account_id}:key/${var.kms_key_id}"
      volume_type = ebs_block_device.value.volume_type
      volume_size = ebs_block_device.value.volume_size
      throughput  = ebs_block_device.value.volume_tput
      iops        = ebs_block_device.value.volume_iops

      tags = merge(var.tags, { Name = "${var.deployment_unique_name}-${ebs_block_device.value.volume_type}" })
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
  }

  lifecycle {
    ignore_changes = [ami, user_data, root_block_device, ebs_block_device, placement_group]
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_recovery" {
  count = var.node_count

  dimensions = {
    InstanceId = local.all_nodes[count.index].id
  }

  alarm_actions       = compact(["arn:${var.aws_partition}:automate:${var.aws_region}:ec2:recover", var.instance_recovery_topic])
  alarm_description   = "Automated EC2 instance recovery alarm for ${var.deployment_unique_name} Node ${count.index + 1} "
  alarm_name          = "${var.deployment_unique_name}-auto-recovery-node${count.index + 1}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
}
