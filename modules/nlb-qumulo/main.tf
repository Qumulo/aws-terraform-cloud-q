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

resource "aws_lb" "int_nlb" {
  name                             = "qumulo-int-${var.random_alphanumeric}"
  enable_cross_zone_load_balancing = var.cross_zone
  enable_deletion_protection       = var.term_protection
  internal                         = !var.is_public
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  subnets                          = var.is_public ? var.public_subnet_ids: var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}-Qumulo Cluster Internal NLB" })
}

resource "aws_lb_target_group" "port_22" {
  name                   = "qumulo-int-22-${var.random_alphanumeric}"
  port                   = 22
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = var.preserve_ip
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_22" {
  count            = var.node_count
  port             = 22
  target_group_arn = aws_lb_target_group.port_22.arn
  target_id        = var.cluster_primary_ips[count.index]
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

resource "aws_lb_target_group" "port_80" {
  name                   = "qumulo-int-80-${var.random_alphanumeric}"
  port                   = 80
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = var.preserve_ip
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_80" {
  count            = var.node_count
  port             = 80
  target_group_arn = aws_lb_target_group.port_80.arn
  target_id        = var.cluster_primary_ips[count.index]
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

resource "aws_lb_target_group" "port_111" {
  name                   = "qumulo-int-111-${var.random_alphanumeric}"
  port                   = 111
  protocol               = "TCP_UDP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = true
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_111" {
  count            = var.node_count
  port             = 111
  target_group_arn = aws_lb_target_group.port_111.arn
  target_id        = var.cluster_primary_ips[count.index]
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

resource "aws_lb_target_group" "port_443" {
  name                   = "qumulo-int-443-${var.random_alphanumeric}"
  port                   = 443
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = var.preserve_ip
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_443" {
  count            = var.node_count
  port             = 443
  target_group_arn = aws_lb_target_group.port_443.arn
  target_id        = var.cluster_primary_ips[count.index]
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

resource "aws_lb_target_group" "port_445" {
  name                   = "qumulo-int-445-${var.random_alphanumeric}"
  port                   = 445
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = var.preserve_ip
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_445" {
  count            = var.node_count
  port             = 445
  target_group_arn = aws_lb_target_group.port_445.arn
  target_id        = var.cluster_primary_ips[count.index]
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

resource "aws_lb_target_group" "port_2049" {
  name                   = "qumulo-int-2049-${var.random_alphanumeric}"
  port                   = 2049
  protocol               = "TCP_UDP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = true
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_2049" {
  count            = var.node_count
  port             = 2049
  target_group_arn = aws_lb_target_group.port_2049.arn
  target_id        = var.cluster_primary_ips[count.index]
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


resource "aws_lb_target_group" "port_3712" {
  name                   = "qumulo-int-3712-${var.random_alphanumeric}"
  port                   = 3712
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = var.preserve_ip
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_3712" {
  count            = var.node_count
  port             = 3712
  target_group_arn = aws_lb_target_group.port_3712.arn
  target_id        = var.cluster_primary_ips[count.index]
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

resource "aws_lb_target_group" "port_8000" {
  name                   = "qumulo-int-8000-${var.random_alphanumeric}"
  port                   = 8000
  protocol               = "TCP"
  target_type            = "ip"
  connection_termination = var.dereg_term
  deregistration_delay   = var.dereg_delay
  preserve_client_ip     = var.preserve_ip
  proxy_protocol_v2      = var.proxy_proto_v2
  vpc_id                 = var.aws_vpc_id

  stickiness {
    enabled = var.stickiness
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_alb_target_group_attachment" "port_8000" {
  count            = var.node_count
  port             = 8000
  target_group_arn = aws_lb_target_group.port_8000.arn
  target_id        = var.cluster_primary_ips[count.index]
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
