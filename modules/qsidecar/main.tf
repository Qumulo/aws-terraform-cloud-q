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

resource "aws_cloudformation_stack" "sidecar" {
  name         = "${var.deployment_unique_name}-sidecar"
  template_url = "https://qumulo-sidecar-us-east-1.s3.amazonaws.com/${var.sidecar_version}/sidecar_cft.json"
  capabilities = ["CAPABILITY_NAMED_IAM"]
  parameters = {
    Hosts         = join(",", var.cluster_primary_ips)
    Password      = var.sidecar_password
    SNSTopic      = var.sidecar_ebs_replacement_topic == null ? "" : var.sidecar_ebs_replacement_topic
    SecurityGroup = var.cluster_security_group_id
    Subnet        = var.sidecar_private_subnet_id
    Username      = var.sidecar_user_name
  }

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}