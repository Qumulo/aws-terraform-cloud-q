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

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
variable "aws_number_azs" {
  description = "AWS Number of AZs"
  type        = number
}
variable "aws_partition" {
  description = "AWS partition"
  type        = string
}
variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "aws_vpc_id" {
  description = "AWS VPC identifier"
  type        = string
}
variable "cluster_floating_ips" {
  description = "List of all floating IPs for the Qumulo cluster"
  type        = list(string)
}
variable "cluster_instance_ids" {
  description = "List of all EC2 instance IDs for the Qumulo cluster"
  type        = list(string)
}
variable "cluster_name" {
  description = "Qumulo cluster name"
  type        = string
}
variable "cluster_max_nodes_down" {
  description = "Maximum number of nodes that may be offline with full cluster functionality"
  type        = number
}
variable "cluster_mod_overness" {
  description = "Increase Node Protection when growing from 1 to 2 nodes per AZ"
  type        = bool
}
variable "cluster_node1_ip" {
  description = "Primary IP for Node 1"
  type        = string
}
variable "cluster_primary_ips" {
  description = "List of all primary IPs for the Qumulo cluster"
  type        = list(string)
}
variable "cluster_secrets_arn" {
  description = "Cluster secrets ARN"
  type        = string
}
variable "cluster_sg_cidrs" {
  description = "AWS security group identifiers"
  type        = list(string)
}
variable "cluster_temporary_password" {
  description = "Temporary password for Qumulo cluster.  Used prior to forming first quorum."
  type        = string
}
variable "cluster_version" {
  description = "Qumulo cluster software version"
  type        = string
}
variable "deployment_unique_name" {
  description = "Unique Name for this Terraform deployment.  This is the deployment name plus 12 random hex digits that will be used for all resource names where appropriate."
  type        = string
}
variable "ec2_key_pair" {
  description = "AWS EC2 key pair"
  type        = string
}
variable "flash_type" {
  description = "OPTIONAL: Specify the type of EBS flash"
  type        = string
}
variable "flash_tput" {
  description = "OPTIONAL: Specify the throughput, in MB/s, for gp3"
  type        = number
}
variable "flash_iops" {
  description = "OPTIONAL: Specify the iops for gp3"
  type        = number
}
variable "functions_s3_prefix" {
  description = "AWS S3 prefix for provisioner functions"
  type        = string
}
variable "instance_type" {
  description = "Qumulo EC2 instance type"
  type        = string
}
variable "kms_key_id" {
  description = "AWS KMS encryption key identifier"
  type        = string
}
variable "permissions_boundary" {
  description = "OPTIONAL: Apply an IAM Permissions Boundary Policy to the Qumulo IAM roles that are created for the provisioning instance. This is an account based policy and is optional. Qumulo's IAM roles conform to the least privilege model."
  type        = string
}
variable "private_subnet_id" {
  description = "AWS private subnet identifier"
  type        = string
}
variable "require_imdsv2" {
  description = "Force all Instance Metadata Service Requests to us v2 Tokens"
  type        = bool
}
variable "s3_bucket_name" {
  description = "AWS S3 bucket name"
  type        = string
}
variable "s3_bucket_region" {
  description = "AWS region the S3 bucket is hosted in"
  type        = string
}
variable "scripts_path" {
  description = "Local path for provisioner scripts"
  type        = string
}
variable "scripts_s3_prefix" {
  description = "AWS S3 prefix for provisioner scripts"
  type        = string
}
variable "sidecar_provision" {
  description = "Provision Qumulo Sidecar"
  type        = bool
}
variable "sidecar_secrets_arn" {
  description = "Sidecar secrets ARN"
  type        = string
}
variable "software_secrets_arn" {
  description = "Software secrets ARN"
  type        = string
}
variable "tags" {
  description = "Additional global tags"
  type        = map(string)
}
variable "term_protection" {
  description = "Enable Termination Protection"
  type        = bool
}
variable "upgrade_s3_prefix" {
  description = "AWS S3 prefix for Qumulo upgrade images"
  type        = string
}