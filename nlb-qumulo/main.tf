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

data "terraform_remote_state" "main" {
  backend = "local"

  config = {
    path = terraform.workspace == "default" ? "../terraform.tfstate" : "../terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

data "aws_ssm_parameter" "nlb-qumulo" {
  name = "/qumulo/${local.deployment_unique_name}/nlb-qumulo/vars"
}

locals {
  deployment_unique_name = data.terraform_remote_state.main.outputs.deployment_unique_name
  aws_vpc_id             = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["aws_vpc_id"]
  cluster_primary_ips    = toset(jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["cluster_primary_ips"])
  cross_zone             = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["cross_zone"]
  dereg_delay            = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["dereg_delay"]
  dereg_term             = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["dereg_term"]
  preserve_ip            = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["preserve_ip"]
  private_subnet_ids     = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["private_subnet_ids"]
  proxy_proto_v2         = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["proxy_proto_v2"]
  random_alphanumeric    = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["random_alphanumeric"]
  stickiness             = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["stickiness"]
  term_protection        = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["term_protection"]
  tags                   = jsondecode(nonsensitive(data.aws_ssm_parameter.nlb-qumulo.value))["tags"]

}

resource "aws_lb" "int_nlb" {
  name                             = "qumulo-int-${local.random_alphanumeric}"
  enable_cross_zone_load_balancing = local.cross_zone
  enable_deletion_protection       = local.term_protection
  internal                         = true
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  subnets                          = local.private_subnet_ids

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}-Qumulo Cluster Internal NLB" })
}

resource "aws_lb_target_group" "port_22" {
  name                   = "qumulo-int-22-${local.random_alphanumeric}"
  port                   = 22
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = local.preserve_ip
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group" "port_80" {
  name                   = "qumulo-int-80-${local.random_alphanumeric}"
  port                   = 80
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = local.preserve_ip
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group" "port_111" {
  name                   = "qumulo-int-111-${local.random_alphanumeric}"
  port                   = 111
  protocol               = "TCP_UDP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = true
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group" "port_443" {
  name                   = "qumulo-int-443-${local.random_alphanumeric}"
  port                   = 443
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = local.preserve_ip
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group" "port_445" {
  name                   = "qumulo-int-445-${local.random_alphanumeric}"
  port                   = 445
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = local.preserve_ip
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group" "port_2049" {
  name                   = "qumulo-int-2049-${local.random_alphanumeric}"
  port                   = 2049
  protocol               = "TCP_UDP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = true
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group" "port_3712" {
  name                   = "qumulo-int-3712-${local.random_alphanumeric}"
  port                   = 3712
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = local.preserve_ip
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group" "port_8000" {
  name                   = "qumulo-int-8000-${local.random_alphanumeric}"
  port                   = 8000
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = local.dereg_term
  deregistration_delay   = local.dereg_delay
  preserve_client_ip     = local.preserve_ip
  proxy_protocol_v2      = local.proxy_proto_v2
  vpc_id                 = local.aws_vpc_id

  stickiness {
    enabled = local.stickiness
    type    = "source_ip"
  }

  tags = merge(local.tags, { Name = "${local.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_22" {
  port             = 22
  target_group_arn = aws_lb_target_group.port_22.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_target_group_attachment" "port_80" {
  port             = 80
  target_group_arn = aws_lb_target_group.port_80.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_target_group_attachment" "port_111" {
  port             = 111
  target_group_arn = aws_lb_target_group.port_111.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_target_group_attachment" "port_443" {
  port             = 443
  target_group_arn = aws_lb_target_group.port_443.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_target_group_attachment" "port_445" {
  port             = 445
  target_group_arn = aws_lb_target_group.port_445.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_target_group_attachment" "port_2049" {
  port             = 2049
  target_group_arn = aws_lb_target_group.port_2049.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_target_group_attachment" "port_3712" {
  port             = 3712
  target_group_arn = aws_lb_target_group.port_3712.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_target_group_attachment" "port_8000" {
  port             = 8000
  target_group_arn = aws_lb_target_group.port_8000.arn
  for_each         = local.cluster_primary_ips
  target_id        = each.value
}

resource "aws_lb_listener" "port_22" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "22"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_22.arn
  }
}

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_80.arn
  }
}

resource "aws_lb_listener" "port_111" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "111"
  protocol          = "TCP_UDP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_111.arn
  }
}

resource "aws_lb_listener" "port_443" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_443.arn
  }
}

resource "aws_lb_listener" "port_445" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "445"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_445.arn
  }
}

resource "aws_lb_listener" "port_2049" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "2049"
  protocol          = "TCP_UDP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_2049.arn
  }
}

resource "aws_lb_listener" "port_3712" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "3712"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_3712.arn
  }
}

resource "aws_lb_listener" "port_8000" {
  load_balancer_arn = aws_lb.int_nlb.arn
  port              = "8000"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_8000.arn
  }
}