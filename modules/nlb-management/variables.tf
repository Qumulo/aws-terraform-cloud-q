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

variable "aws_vpc_id" {
  description = "AWS VPC identifier"
  type        = string
}
variable "cluster_primary_ips" {
  description = "List of all primary IPs for the Qumulo cluster"
  type        = list(string)
}
variable "deployment_unique_name" {
  description = "Unique Name for this Terraform deployment.  This is the deployment name plus 12 random hex digits that will be used for all resource names where appropriate."
  type        = string
}
variable "node_count" {
  description = "Qumulo cluster node count"
  type        = number
}
variable "public_replication_provision" {
  description = "Enable port 3712 for Qumulo replication on the public NLB listener"
  type        = bool
}
variable "public_subnet_ids" {
  description = "AWS public subnet identifiers"
  type        = list(string)
}
variable "random_alphanumeric" {
  description = "Alphanumeric portion of deployment unique name"
  type        = string
}
variable "tags" {
  description = "Additional global tags"
  type        = map(string)
}
