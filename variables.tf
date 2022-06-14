#MIT License

#Copyright (c) 2022 Qumulo, Inc.

#Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal 
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions =

#The above copyright notice and this permission notice shall be included in all 
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
#SOFTWARE.

variable "aws_region" {
  description = "AWS region"
  type        = string
  nullable    = false
}
variable "aws_vpc_id" {
  description = "AWS VPC identifier"
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^vpc-", var.aws_vpc_id))
    error_message = "The aws_vpc_id must be a valid VPC ID of the form 'vpc-'."
  }
}
variable "deployment_name" {
  description = "Name for this Terraform deployment.  This name plus 11 random hex digits will be used for all resource names where appropriate."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9A-Za-z\\-]{2,32}$", var.deployment_name))
    error_message = "The deployment_name must be a <=32 characters long and use 0-9 A-Z a-z or dash (-)."
  }
}
variable "dev_environment" {
  description = "Enables the use of m5.xlarge instance type.  NOT recommended for production and overridden when not a development environment."
  type        = bool
  default     = false
}
variable "ec2_key_pair" {
  description = "AWS EC2 key pair"
  type        = string
  nullable    = false
}
variable "kms_key_id" {
  description = "OPTIONAL: AWS KMS encryption key identifier"
  type        = string
  default     = null
  validation {
    condition     = var.kms_key_id == null || can(regex("^[0-9A-Za-z]{8}[-][0-9A-Za-z]{4}[-][0-9A-Za-z]{4}[-][0-9A-Za-z]{4}[-][0-9A-Za-z]{12}$", var.kms_key_id))
    error_message = "The kms_key_id must be an alphanumeric value formated 12345678-1234-1234-1234-1234567890ab."
  }
}
variable "private_subnet_id" {
  description = "AWS private subnet identifier"
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^subnet-", var.private_subnet_id))
    error_message = "The private_subnet_id must be a valid Subnet ID of the form 'subnet-'."
  }
}
variable "public_subnet_id" {
  description = "OPTIONAL: Public Subnet ID for management NLB."
  type        = string
  default     = null
  validation {
    condition     = var.public_subnet_id == null || can(regex("^subnet-", var.public_subnet_id))
    error_message = "The public_subnet_id must be a valid Subnet ID of the form 'subnet-'."
  }
}
variable "q_ami_id" {
  description = "OPTIONAL: Qumulo AMI-ID"
  type        = string
  default     = null
  validation {
    condition     = var.q_ami_id == null || can(regex("^ami-[0-9A-Za-z]{17}$", var.q_ami_id))
    error_message = "The q_ami_id must be a valid AMI ID of the form 'ami-0123456789abcdefg'."
  }
}
variable "q_audit_logging" {
  description = "OPTIONAL: Configure a CloudWatch Log group to store Audit logs from Qumulo"
  type        = bool
  default     = false
}
variable "q_cluster_additional_sg_cidrs" {
  description = "OPTIONAL: AWS additional security group CIDRs for the Qumulo cluster"
  type        = string
  default     = null
  validation {
    condition     = var.q_cluster_additional_sg_cidrs == null || can(regex("^(((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9])))[,]\\s*)*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9])))$", var.q_cluster_additional_sg_cidrs))
    error_message = "The q_cluster_additional_sg_cidrs must be a valid comma delimited string of CIDRS of the form '10.0.1.0/24, 10.10.3.0/24, 172.16.30.0/24'."
  }
}
variable "q_cluster_name" {
  description = "Qumulo cluster name"
  type        = string
  default     = "Cloud-Q"
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9\\-]{0,13}[a-zA-Z0-9]$", var.q_cluster_name))
    error_message = "The q_cluster_name must be an alphanumeric string between 2 and 15 characters. Dash (-) is allowed if not the first or last character."
  }
}
variable "q_cluster_version" {
  description = "Qumulo cluster software version"
  type        = string
  default     = "4.2.0"
  validation {
    condition     = can(regex("^((4\\.[2-3]\\.[0-9][0-9]?\\.?[0-9]?[0-9]?)|([5-9][0-9]?\\.[0-3]\\.[0-9][0-9]?\\.?[0-9]?[0-9]?))$", var.q_cluster_version))
    error_message = "The q_cluster_version 4.2.0 or greater. Examples: 4.2.1, 5.0.0.1, 5.3.10."
  }
}
variable "q_cluster_admin_password" {
  description = "Qumulo cluster admin password"
  type        = string
  sensitive   = true
  nullable    = false
  validation {
    condition     = can(regex("^(.{0,7}|[^0-9]*|[^A-Z]*|[^a-z]*|[a-zA-Z0-9]*)$", var.q_cluster_admin_password)) ? false : true
    error_message = "The q_cluster_admin_password must be at least 8 characters and contain an uppercase, lowercase, number, and special character."
  }
}
variable "q_disk_config" {
  description = "OPTIONAL: Qumulo disk config"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.q_disk_config == null,
      var.q_disk_config == "600GiB-AF",
      var.q_disk_config == "1TB-AF",
      var.q_disk_config == "5TB-AF",
      var.q_disk_config == "8TiB-AF",
      var.q_disk_config == "13TiB-AF",
      var.q_disk_config == "20TiB-AF",
      var.q_disk_config == "30TB-AF",
      var.q_disk_config == "35TiB-AF",
      var.q_disk_config == "55TiB-AF",
      var.q_disk_config == "5TB-Hybrid-st1",
      var.q_disk_config == "8TiB-Hybrid-st1",
      var.q_disk_config == "13TiB-Hybrid-st1",
      var.q_disk_config == "20TB-Hybrid-st1",
      var.q_disk_config == "35TiB-Hybrid-st1",
      var.q_disk_config == "55TiB-Hybrid-st1",
      var.q_disk_config == "90TiB-Hybrid-st1",
      var.q_disk_config == "160TiB-Hybrid-st1",
      var.q_disk_config == "256TiB-Hybrid-st1",
      var.q_disk_config == "320TiB-Hybrid-st1",
      var.q_disk_config == "8TiB-Hybrid-sc1",
      var.q_disk_config == "13TiB-Hybrid-sc1",
      var.q_disk_config == "20TB-Hybrid-sc1",
      var.q_disk_config == "35TiB-Hybrid-sc1",
      var.q_disk_config == "55TiB-Hybrid-sc1",
      var.q_disk_config == "90TiB-Hybrid-sc1",
      var.q_disk_config == "160TiB-Hybrid-sc1",
      var.q_disk_config == "256TiB-Hybrid-sc1",
      var.q_disk_config == "320TiB-Hybrid-sc1"
    ])
    error_message = "An invalid EBS disk config was specified. See the .tfvars file comments for valid disk config strings."
  }
}
variable "q_flash_type" {
  description = "OPTIONAL: Specify the type of EBS flash"
  type        = string
  default     = "gp3"
  validation {
    condition = anytrue([
      var.q_flash_type == "gp2",
      var.q_flash_type == "gp3"
    ])
    error_message = "An invalid EBS flash type was specified. Must be gp2 or gp3."
  }
}
variable "q_flash_tput" {
  description = "OPTIONAL: Specify the throughput, in MB/s, for gp3"
  type        = number
  default     = 250
  validation {
    condition     = var.q_flash_tput >= 125 && var.q_flash_tput <= 1000
    error_message = "EBS gp3 throughput must be in the range of 125 to 1000 MB/s."
  }
}
variable "q_flash_iops" {
  description = "OPTIONAL: Specify the iops for gp3"
  type        = number
  default     = 3000
  validation {
    condition     = var.q_flash_iops >= 3000 && var.q_flash_iops <= 16000
    error_message = "EBS gp3 IOPS must be in the range of 3000 to 16000."
  }
}
variable "q_floating_ips_per_node" {
  description = "Qumulo floating IP addresses per node"
  type        = number
  default     = 3
  validation {
    condition     = var.q_floating_ips_per_node >= 1 && var.q_floating_ips_per_node <= 4
    error_message = "Specify 1, 2, 3, or 4 floating IPs per Qumulo instance."
  }
}
variable "q_fqdn_name" {
  description = "OPTIONAL: The Fully Qualified Domain Name (FQDN) for Route 53 Private Hosted Zone "
  type        = string
  default     = null
  validation {
    condition     = var.q_fqdn_name == null || can(regex("^[0-9A-Za-z\\.\\-]*$", var.q_fqdn_name))
    error_message = "The q_fqdn_name may only contain alphanumeric values and dashes (-) and/or dots (.)."
  }
}
variable "q_instance_recovery_topic" {
  description = "OPTIONAL: AWS SNS topic for Qumulo instance recovery"
  type        = string
  default     = null
}
variable "q_instance_type" {
  description = "Qumulo EC2 instance type"
  type        = string
  default     = "m5.2xlarge"
  nullable    = false
  validation {
    condition = anytrue([
      var.q_instance_type == "m5.xlarge",
      var.q_instance_type == "m5.2xlarge",
      var.q_instance_type == "m5.4xlarge",
      var.q_instance_type == "m5.8xlarge",
      var.q_instance_type == "m5.12xlarge",
      var.q_instance_type == "m5.16xlarge",
      var.q_instance_type == "m5.24xlarge",
      var.q_instance_type == "c5n.4xlarge",
      var.q_instance_type == "c5n.9xlarge",
      var.q_instance_type == "c5n.18xlarge",
      var.q_instance_type == "c5d.9xlarge"
    ])
    error_message = "Only m5 and c5n instance types are supported.  Must be >=m5.xlarge or >=c5n.4xlarge. m5.xlarge is only supported with dev_envrionment=true."
  }
}
variable "q_local_zone_or_outposts" {
  description = "Is the Qumulo cluster being deployed in a local zone or on Outposts?"
  type        = bool
  default     = false
}
variable "q_marketplace_type" {
  description = "Qumulo AWS marketplace type"
  type        = string
  nullable    = false
  validation {
    condition = anytrue([
      var.q_marketplace_type == "1TB-Usable-All-Flash",
      var.q_marketplace_type == "12TB-Usable-Hybrid-st1",
      var.q_marketplace_type == "96TB-Usable-Hybrid-st1",
      var.q_marketplace_type == "103TB-Usable-All-Flash",
      var.q_marketplace_type == "270TB-Usable-Hybrid-st1",
      var.q_marketplace_type == "809TB-Usable-Hybrid-st1",
      var.q_marketplace_type == "Custom-1TB-6PB",
      var.q_marketplace_type == "Specified-AMI-ID"
    ])
    error_message = "The q_marketplace_type must be 1TB-Usable-All-Flash, 12TB-Usable-Hybrid-st1, 96TB-Usable-Hybrid-st1, 103TB-Usable-All-Flash, 270TB-Usable-Hybrid-st1, 809TB-Usable-Hybrid-st1, Custom-1TB-6PB, or Specified-AMI-ID offering. Choose the appropriate offering."
  }
}
variable "q_node_count" {
  description = "Qumulo cluster node count"
  type        = number
  default     = 0
  validation {
    condition     = var.q_node_count == 0 || (var.q_node_count >= 4 && var.q_node_count <= 20)
    error_message = "The q_node_count value is mandatory with the marketplace offers Custom-1TB-6PB and Specified-AMI-ID. It is also used to grow a cluster. Specify 4 to 20 nodes. 0 is the default and implies a marketplace config lookup."
  }
}
/*
variable "q_nodes_per_az" {
  description = "IGNORE: For Future Use - Qumulo nodes per AZ."
  type        = number
  default     = 0
  validation {
    condition     = var.q_nodes_per_az == 0 || (var.q_nodes_per_az >= 1 && var.q_nodes_per_az <= 3)
    error_message = "The q_nodes_per_az value is required when specifying multiple subnets (AZs). It is also used to grow a multi-AZ cluster. Specify 0 or 1-3. 0 is the default and implies a single AZ deployment."
  }
}
*/
variable "q_permissions_boundary" {
  description = "OPTIONAL: Apply an IAM Permissions Boundary Policy to the Qumulo IAM roles that are created for the Qumulo cluster and provisioning instance. This is an account based policy and is optional. Qumulo's IAM roles conform to the least privilege model."
  type        = string
  default     = null
}
variable "q_public_replication_provision" {
  description = "OPTIONAL: Enable port 3712 for replication from on-prem Qumulo systems using the public IP of the NLB for Qumulo Managment. Requires q_public_management_provision=true above."
  type        = bool
  default     = false
}
variable "q_record_name" {
  description = "OPTIONAL: The record name for the Route 53 Private Hosted Zone. This will add a prefix to the q_fqdn_name above"
  type        = string
  default     = null
  validation {
    condition     = var.q_record_name == null || can(regex("^[0-9A-Za-z]*$", var.q_record_name))
    error_message = "The q_record_name may only contain alphanumeric values."
  }
}
variable "q_route53_provision" {
  description = "OPTIONAL: Configure Route 53 DNS for Floating IPs."
  type        = bool
  default     = false
}
variable "q_sidecar_private_subnet_id" {
  description = "OPTIONAL: Private Subnet ID for Sidecar Lambdas if the cluster is being deployed in a local zone or on Outpost"
  type        = string
  default     = null
  validation {
    condition     = var.q_sidecar_private_subnet_id == null || can(regex("^subnet-", var.q_sidecar_private_subnet_id))
    error_message = "The q_sidecar_private_subnet_id must be a valid Subnet ID of the form 'subnet-' or null if not deploying in a local zone or on Outposts."
  }
}
variable "q_sidecar_provision" {
  description = "Provision Qumulo Sidecar"
  type        = bool
  default     = true
}
variable "q_sidecar_user_name" {
  description = "Qumulo Sidecar username"
  type        = string
  default     = "SideCarUser"
  nullable    = false
}
variable "q_sidecar_version" {
  description = "Qumulo Sidecar software version"
  type        = string
  default     = "5.1.0.1"
  nullable    = false
  validation {
    condition     = can(regex("^((4\\.[2-3]\\.[0-9][0-9]?\\.?[0-9]?[0-9]?)|([5-9][0-9]?\\.[0-3]\\.[0-9][0-9]?\\.?[0-9]?[0-9]?))$", var.q_sidecar_version))
    error_message = "The q_sidecar_version 4.2.0 or greater. Examples: 4.2.1, 5.0.0.1, 5.3.10.  It also should match the version running on the cluster."
  }
}
variable "q_sidecar_ebs_replacement_topic" {
  description = "AWS SNS topic for Qumulo Sidecar replacement of a failed EBS volume."
  type        = string
  default     = null
}
variable "s3_bucket_name" {
  description = "AWS S3 bucket name"
  type        = string
  nullable    = false
}
variable "s3_bucket_prefix" {
  description = "AWS S3 bucket prefix (path).  Include a trailing slash (/)"
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^.*/$", var.s3_bucket_prefix))
    error_message = "The s3_bucket_prefix must end with a /."
  }
}
variable "s3_bucket_region" {
  description = "AWS region the S3 bucket is hosted in"
  type        = string
  nullable    = false
}
variable "tags" {
  description = "OPTIONAL: Additional global tags"
  type        = map(string)
  default     = null
}
variable "term_protection" {
  description = "Enable Termination Protection"
  type        = bool
  default     = true
}
