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

resource "aws_route53_zone" "qumulo_hosted_zone" {
  name = var.fqdn_name

  vpc {
    vpc_id = var.aws_vpc_id
  }

  tags = merge({ Name = "${var.deployment_unique_name}" }, var.tags)
}

resource "aws_route53_record" "qumulo_fips" {
  name    = var.record_name
  records = toset(var.cluster_floating_ips)
  ttl     = "1"
  type    = "A"
  zone_id = aws_route53_zone.qumulo_hosted_zone.zone_id

  # for_each creates an unknown number of records such that terraform target is required, or this module 
  # has to be a seperate module with a hook back to tf state for the top-level tf.  There's no advantage
  # for equal weighted records.  The behavior with either approach will yield an equal probablity for floating
  # IPs
  /* 
  weighted_routing_policy {
    weight = 0
  }

  for_each       = toset(var.cluster_floating_ips)
  set_identifier = "Qumulo FIP ${each.value}"
  records        = [each.value]
  */
}