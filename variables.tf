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
}
variable "aws_vpc_id" {
  description = "AWS VPC identifier"
  type        = string
}
variable "deployment_name" {
  description = "Name for this Terraform deployment.  This name plus 12 random hex digits will be used for all resource names where appropriate."
  type        = string
}
variable "dev_environment" {
  description = "Enables the use of m5.xlarge instance type.  NOT recommended for production and overridden when not a development environment."
  type        = bool
  default     = false
}
variable "ec2_key_pair" {
  description = "AWS EC2 key pair"
  type        = string
}
variable "kms_key_id" {
  description = "OPTIONAL: AWS KMS encryption key identifier"
  type        = string
  default     = null
}
variable "private_subnet_id" {
  description = "AWS private subnet identifier"
  type        = string
}
variable "public_subnet_id" {
  description = "OPTIONAL: Public Subnet ID for management NLB."
  type        = string
  default     = null
}
variable "q_ami_id" {
  description = "OPTIONAL: Qumulo AMI-ID"
  type        = string
  default     = null
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
}
variable "q_cluster_name" {
  description = "Qumulo cluster name"
  type        = string
  default     = "Cloud-Q"
}
variable "q_cluster_version" {
  description = "Qumulo cluster software version"
  type        = string
  default     = "4.2.0"
}
variable "q_cluster_admin_password" {
  description = "Qumulo cluster admin password"
  type        = string
  sensitive   = true
}
variable "q_disk_config" {
  description = "OPTIONAL: Qumulo disk config"
  type        = string
  default     = null
}
variable "q_floating_ips_per_node" {
  description = "Qumulo floating IP addresses per node"
  type        = number
  default     = 3

  validation {
    condition     = (var.q_floating_ips_per_node >= 1 && var.q_floating_ips_per_node <= 4)
    error_message = "Specify 1, 2, 3, or 4 floating IPs per Qumulo instance."
  }
}
variable "q_fqdn_name" {
  description = "OPTIONAL: The Fully Qualified Domain Name (FQDN) for Route 53 Private Hosted Zone "
  type        = string
  default     = null
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

  validation {
    condition     = can(regex("^(m5.2xlarge|m5.4xlarge|m5.8xlarge|m5.12xlarge|m5.16xlarge|m5.24xlarge|c5n.4xlarge|c5n.9xlarge|c5n.18xlarge)$", var.q_instance_type))
    error_message = "Only m5 and c5n instance types are supported.  Must be >=m5.2xlarge or >=c5n.4xlarge."
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

  /*validation {
    condition     = can(regex("^(1TB-Usable-All-Flash)$", var.q_marketplace_type))
    error_message = "Specify 1, 2, 3, or 4 floating IPs per Qumulo instance."
  }*/
}
variable "q_node_count" {
  description = "Qumulo cluster node count"
  type        = number
  default     = 0

  validation {
    condition     = (var.q_node_count == 0 || (var.q_node_count >= 4 && var.q_node_count <= 20))
    error_message = "If using a Customizable marketplace offer specify 4 to 20 nodes."
  }
}
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
}
variable "q_route53_provision" {
  description = "Optional: Configure Route 53 DNS for Floating IPs."
  type        = bool
  default     = false
}
variable "q_sidecar_private_subnet_id" {
  description = "OPTIONAL: Private Subnet ID for Sidecar Lambdas if the cluster is being deployed in a local zone or on Outpost"
  type        = string
  default     = null
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
}
variable "q_sidecar_version" {
  description = "Qumulo Sidecar software version"
  type        = string
  default     = "4.2.0"
}
variable "q_sidecar_ebs_replacement_topic" {
  description = "AWS SNS topic for Qumulo Sidecar replacement of a failed EBS volume."
  type        = string
  default     = null
}
variable "s3_bucket_name" {
  description = "AWS S3 bucket name"
  type        = string
}
variable "s3_bucket_prefix" {
  description = "AWS S3 bucket prefix (path).  Include a trailing slash (/)"
  type        = string
}
variable "s3_bucket_region" {
  description = "AWS region the S3 bucket is hosted in"
  type        = string
}
variable "tags" {
  description = "Additional global tags"
  type        = map(string)
  default     = null
}
variable "term_protection" {
  description = "Enable Termination Protection"
  type        = bool
  default     = true
}

variable "q_marketplace_map" {
  description = "Qumulo marketplace selection mapped to disk config, node count, and short name"
  type = map(object({
    DiskConfig = string
    NodeCount  = number
    ShortName  = string
  }))
  default = {
    "1TB-Usable-All-Flash" = {
      DiskConfig = "600GiB-AF"
      NodeCount  = 4
      ShortName  = "1TB"
    }
    "12TB-Usable-Hybrid-st1" = {
      DiskConfig = "5TB-Hybrid-st1"
      NodeCount  = 4
      ShortName  = "12TB"
    }
    "96TB-Usable-Hybrid-st1" = {
      DiskConfig = "20TB-Hybrid-st1"
      NodeCount  = 6
      ShortName  = "96TB"
    }
    "103TB-Usable-All-Flash" = {
      DiskConfig = "30TB-AF"
      NodeCount  = 5
      ShortName  = "103TB"
    }
    "270TB-Usable-Hybrid-st1" = {
      DiskConfig = "55TiB-Hybrid-st1"
      NodeCount  = "6"
      ShortName  = "270TB"
    }
    "809TB-Usable-Hybrid-st1" = {
      DiskConfig = "160TiB-Hybrid-st1"
      NodeCount  = 6
      ShortName  = "809TB"
    }
    "Custom-1TB-6PB" = {
      DiskConfig = "CUSTOM-ERROR-NEED-TO-SELECT-DISK-CONFIG"
      NodeCount  = 0
      ShortName  = "Custom"
    }
    "Specified-AMI-ID" = {
      DiskConfig = "SPECIFIED-AMI-ID-ERROR-NEED-TO-SELECT-DISK-CONFIG"
      NodeCount  = 0
      ShortName  = "Custom"
    }
  }
}
