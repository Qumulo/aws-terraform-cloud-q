#MIT License

#Copyright (c) 2022 Qumulo, Inc.

#Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal 
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all 
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
#SOFTWARE.

data "aws_iam_policy" "secrets" {
  arn = "arn:${var.aws_partition}:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  kms_arn   = var.kms_key_id == null ? "*" : "arn:${var.aws_partition}:kms:${var.aws_region}:${var.aws_account_id}:key/${var.kms_key_id}"
  allow_cmk = var.kms_key_id == null ? "Deny" : "Allow"

  ingress_rules = [
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
      port        = 443
      description = "TCP ports for HTTPS"
      protocol    = "tcp"
    }
  ]
}

resource "aws_security_group" "provisioner" {
  name        = "${var.deployment_unique_name}-qumulo-provisioner"
  description = "Enable ports to provisioner instance"
  vpc_id      = var.aws_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_iam_role" "provisioner_access" {
  name = "${var.deployment_unique_name}-qumulo-provisioner"

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

resource "aws_iam_instance_profile" "provisioner_access" {
  name = "${var.deployment_unique_name}-qumulo-provisioner"
  role = aws_iam_role.provisioner_access.name
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.provisioner_access.name
  policy_arn = data.aws_iam_policy.secrets.arn
}

resource "aws_iam_role_policy" "policy1" {
  name   = "s3-policy"
  role   = aws_iam_role.provisioner_access.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",        
      "Action": [
        "s3:GetObject",
        "s3:ListObject"
      ],
      "Resource": [
        "arn:${var.aws_partition}:s3:::${var.s3_bucket_name}/*",
        "arn:${var.aws_partition}:s3:::${var.s3_bucket_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy2" {
  name   = "EC2-Labmda-SSM-policy"
  role   = aws_iam_role.provisioner_access.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:DescribeStackResource",
        "cloudformation:DescribeStackResources",
        "cloudformation:DescribeStacks",
        "cloudformation:SetStackPolicy",
        "cloudformation:UpdateTerminationProtection",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyVolume",
        "kms:Decrypt",
        "lambda:GetFunction",
        "lambda:ListFunctions",
        "lambda:ListTags",
        "ssm:GetParameter",
        "ssm:ListInstanceAssociations",
        "ssm:PutParameter",
        "ssm:UpdateInstanceInformation"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy3" {
  name   = "KMS-policy"
  role   = aws_iam_role.provisioner_access.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "${local.allow_cmk}",        
      "Action": [
        "kms:PutKeyPolicy",
        "kms:GetKeyPolicy"
      ],
      "Resource": "${local.kms_arn}"
    }
  ]
}
EOF
}

resource "aws_ssm_parameter" "creation-version" {
  name  = "/qumulo/${var.deployment_unique_name}/creation-version"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "installed-version" {
  name  = "/qumulo/${var.deployment_unique_name}/installed-version"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "instance-ids" {
  name  = "/qumulo/${var.deployment_unique_name}/instance-ids"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "node-ips" {
  name  = "/qumulo/${var.deployment_unique_name}/node-ips"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "float-ips" {
  name  = "/qumulo/${var.deployment_unique_name}/float-ips"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "uuid" {
  name  = "/qumulo/${var.deployment_unique_name}/uuid"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "last-run-status" {
  name  = "/qumulo/${var.deployment_unique_name}/last-run-status"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "sidecar-provisioned" {
  name  = "/qumulo/${var.deployment_unique_name}/sidecar-provisioned"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "cmk-policy-modified" {
  name  = "/qumulo/${var.deployment_unique_name}/cmk-policy-modified"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}

resource "aws_network_interface" "provisioner" {
  security_groups = [aws_security_group.provisioner.id]
  subnet_id       = var.private_subnet_id

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}-provisioner}" })
}

resource "aws_instance" "provisioner" {
  ami                     = data.aws_ami.amzn2.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = aws_iam_instance_profile.provisioner_access.name
  instance_type           = var.instance_type
  key_name                = var.ec2_key_pair
  user_data = templatefile("${var.scripts_path}user-data.sh", {
    bucket_name            = var.s3_bucket_name
    bucket_region          = var.s3_bucket_region
    cluster_name           = var.cluster_name
    cluster_secrets_arn    = var.cluster_secrets_arn
    deployment_unique_name = var.deployment_unique_name
    flash_tput             = var.flash_tput
    flash_iops             = var.flash_iops
    floating_ips           = join(",", var.cluster_floating_ips)
    functions_s3_prefix    = var.functions_s3_prefix
    instance_ids           = join(",", var.cluster_instance_ids)
    kms_key_id             = var.kms_key_id == null ? "" : "arn:${var.aws_partition}:kms:${var.aws_region}:${var.aws_account_id}:key/${var.kms_key_id}"
    max_nodes_down         = tostring(var.cluster_max_nodes_down)
    mod_overness           = var.cluster_mod_overness == true ? "YES" : "NO"
    node1_ip               = var.cluster_node1_ip
    number_azs             = tostring(var.aws_number_azs)
    primary_ips            = join(",", var.cluster_primary_ips)
    region                 = var.aws_region
    scripts_path           = var.scripts_path
    scripts_s3_prefix      = var.scripts_s3_prefix
    sidecar_provision      = var.sidecar_provision == true ? "YES" : "NO"
    sidecar_secrets_arn    = var.sidecar_secrets_arn
    software_secrets_arn   = var.software_secrets_arn
    temporary_password     = var.cluster_temporary_password
    upgrade_s3_prefix      = var.upgrade_s3_prefix
    version                = var.cluster_version
  })

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}-provisioner" })

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.provisioner.id
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = var.kms_key_id == null ? "" : "arn:${var.aws_partition}:kms:${var.aws_region}:${var.aws_account_id}:key/${var.kms_key_id}"
    volume_type = var.flash_type
    volume_size = 40

    tags = merge(var.tags, { Name = "${var.deployment_unique_name}-provisioner" })
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
  }

  lifecycle {
    ignore_changes = [root_block_device[0].kms_key_id]
  }
}

#This resource monitors the status of the qprovisioner module (EC2 Instance) that executes secondary provisioning of the Qumulo cluster.
#It pulls status from SSM Parameter Store where the provisioner writest status/state.
locals {
  is_windows  = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  status_sh   = "${var.scripts_path}status.sh"
  status_ps1  = "${var.scripts_path}status.ps1"
  status_vars = { aws_region = var.aws_region, deployment_unique_name = var.deployment_unique_name, aws_instance_id = aws_instance.provisioner.id }
}

data "aws_ssm_parameter" "qprovisioner" {
  name = "/qumulo/${var.deployment_unique_name}/last-run-status"

  depends_on = [null_resource.provisioner_status]
}

resource "null_resource" "provisioner_status" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = local.is_windows ? templatefile(local.status_ps1, local.status_vars) : templatefile(local.status_sh, local.status_vars)
  }

  triggers = {
    instance_id = aws_instance.provisioner.id
  }

  depends_on = [aws_instance.provisioner]
}