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

resource "aws_lb" "mgmt_nlb" {
  name               = "qumulo-pub-${var.random_alphanumeric}"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}-Qumulo Public Management NLB" })
}

resource "aws_lb_target_group" "port_443" {
  name        = "qumulo-pub-443-${var.random_alphanumeric}"
  port        = 443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.aws_vpc_id

  stickiness {
    enabled = true
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
  load_balancer_arn = aws_lb.mgmt_nlb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_443.arn
  }
}

resource "aws_lb_target_group" "port_3712" {
  count = var.public_replication_provision ? 1 : 0

  name        = "qumulo-pub-3712-${var.random_alphanumeric}"
  port        = 3712
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.aws_vpc_id

  stickiness {
    enabled = true
    type    = "source_ip"
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_lb_target_group_attachment" "port_3712" {
  count            = var.public_replication_provision ? var.node_count : 0
  port             = 3712
  target_group_arn = aws_lb_target_group.port_3712[0].arn
  target_id        = var.cluster_primary_ips[count.index]
}

resource "aws_lb_listener" "port_3712" {
  count = var.public_replication_provision ? 1 : 0

  load_balancer_arn = aws_lb.mgmt_nlb.arn
  port              = "3712"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_3712[0].arn
  }
}
