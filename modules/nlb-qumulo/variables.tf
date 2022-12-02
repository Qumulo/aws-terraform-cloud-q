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
variable "cross_zone" {
  description = "AWS NLB Enable cross-AZ load balancing"
  type        = bool
}
variable "deployment_unique_name" {
  description = "Unique Name for this Terraform deployment.  This is the deployment name plus 12 random hex digits that will be used for all resource names where appropriate."
  type        = string
}
variable "dereg_delay" {
  description = "AWS NLB deregistration delay"
  type        = number
}
variable "dereg_term" {
  description = "AWS NLB terminate connection on deregistration"
  type        = bool
}
variable "node_count" {
  description = "Qumulo cluster node count"
  type        = number
}
variable "preserve_ip" {
  description = "AWS NLB preserve IP address"
  type        = bool
}
variable "private_subnet_ids" {
  description = "AWS private subnet identifiers"
  type        = list(string)
}
variable "proxy_proto_v2" {
  description = "AWS NLB proxy header"
  type        = bool
}
variable "random_alphanumeric" {
  description = "Alphanumeric portion of deployment unique name"
  type        = string
}
variable "stickiness" {
  description = "AWS NLB sticky sessions"
  type        = bool
}
variable "is_public" {
  description = "OPTIONAL: Makes the NLB for the cluster internal, setting this to true will allow anyone to reach the cluster"
  type        = bool
  default     = false
}
variable "tags" {
  description = "Additional global tags"
  type        = map(string)
}
variable "term_protection" {
  description = "Enable Termination Protection"
  type        = bool
}
