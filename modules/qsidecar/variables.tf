#MIT License

#Copyright (c) 2021 Qumulo, Inc.

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

variable "deployment_unique_name" {
  description = "Unique Name for this Terraform deployment.  This is the deployment name plus 12 random alphanumeric digits that will be used for all resource names where appropriate."
  type        = string
}
variable "cluster_primary_ips" {
  description = "Qumulo cluster primary IPs for Sidecar monitoring"
  type        = list(string)
}
variable "cluster_security_group_id" {
  description = "Qumulo Cluster security group identifier"
  type        = string
}
variable "sidecar_ebs_replacement_topic" {
  description = "AWS SNS topic for Qumulo Sidecar replacement of a failed EBS volume."
  type        = string
}
variable "sidecar_password" {
  description = "Qumulo Sidecar password"
  type        = string
  sensitive   = true
}
variable "sidecar_private_subnet_id" {
  description = "Qumulo Sidecar private subnet identifier"
  type        = string
}
variable "sidecar_user_name" {
  description = "Qumulo Sidecar user name"
  type        = string
}
variable "sidecar_version" {
  description = "Qumulo Sidecar software version"
  type        = string
}
variable "tags" {
  description = "Additional global tags"
  type        = map(string)
}
