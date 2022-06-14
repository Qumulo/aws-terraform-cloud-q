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

variable "ami_id" {
  description = "Qumulo AMI-ID"
  type        = string
}
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
variable "cluster_name" {
  description = "Qumulo cluster name"
  type        = string
}
variable "cluster_sg_cidrs" {
  description = "AWS security group identifiers"
  type        = list(string)
}
variable "deployment_unique_name" {
  description = "Unique Name for this Terraform deployment.  This is the deployment name plus 12 random hex digits that will be used for all resource names where appropriate."
  type        = string
}
variable "disk_config" {
  description = "Qumulo disk config"
  type        = string
}
variable "ec2_key_pair" {
  description = "AWS EC2 key pair"
  type        = string
}
variable "floating_ips_per_node" {
  description = "Qumulo floating IP addresses per node"
  type        = number
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
variable "instance_recovery_topic" {
  description = "AWS SNS topic for Qumulo instance recovery"
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
variable "node_count" {
  description = "Qumulo cluster node count"
  type        = number
}
variable "permissions_boundary" {
  description = "OPTIONAL: Apply an IAM Permissions Boundary Policy to the Qumulo IAM roles that are created for the Qumulo cluste. This is an account based policy and is optional. Qumulo's IAM roles conform to the least privilege model."
  type        = string
}
variable "private_subnet_ids" {
  description = "AWS private subnet identifiers"
  type        = list(string)
}
variable "require_imdsv2" {
  description = "Force all Instance Metadata Service Requests to us v2 Tokens"
  type        = bool
}
variable "tags" {
  description = "Additional global tags"
  type        = map(string)
}
variable "term_protection" {
  description = "Enable Termination Protection"
  type        = bool
}
variable "disk_map" {
  description = "This map is used to build the disk configuration for each Qumulo node. It maps working SSDs and backing HDDs in the correct numbers and sizes to the correct slots"
  type = map(object({
    slotCount : number
    workingSlots : number
    workingSize : number
    backingSlots : number
    backingType : string
    backingSize : number
  }))
  default = {
    "600GiB-AF" = {
      slotCount    = 6
      workingSlots = 6
      workingSize  = 100
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "1TB-AF" = {
      slotCount    = 8
      workingSlots = 8
      workingSize  = 128
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "5TB-AF" = {
      slotCount    = 10
      workingSlots = 10
      workingSize  = 500
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "8TiB-AF" = {
      slotCount    = 16
      workingSlots = 16
      workingSize  = 512
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "13TiB-AF" = {
      slotCount    = 25
      workingSlots = 25
      workingSize  = 533
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "20TiB-AF" = {
      slotCount    = 25
      workingSlots = 25
      workingSize  = 820
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "30TB-AF" = {
      slotCount    = 8
      workingSlots = 8
      workingSize  = 3750
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "35TiB-AF" = {
      slotCount    = 25
      workingSlots = 25
      workingSize  = 1434
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "55TiB-AF" = {
      slotCount    = 25
      workingSlots = 25
      workingSize  = 2253
      backingSlots = 0
      backingType  = "none"
      backingSize  = 0
    }
    "5TB-Hybrid-st1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 100
      backingSlots = 10
      backingType  = "st1"
      backingSize  = 500
    }
    "8TiB-Hybrid-st1" = {
      slotCount    = 12
      workingSlots = 4
      workingSize  = 150
      backingSlots = 8
      backingType  = "st1"
      backingSize  = 1024
    }
    "13TiB-Hybrid-st1" = {
      slotCount    = 12
      workingSlots = 4
      workingSize  = 175
      backingSlots = 8
      backingType  = "st1"
      backingSize  = 1664
    }
    "20TB-Hybrid-st1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 160
      backingSlots = 10
      backingType  = "st1"
      backingSize  = 2000
    }
    "35TiB-Hybrid-st1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 350
      backingSlots = 10
      backingType  = "st1"
      backingSize  = 3584
    }
    "55TiB-Hybrid-st1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 550
      backingSlots = 10
      backingType  = "st1"
      backingSize  = 5632
    }
    "90TiB-Hybrid-st1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 900
      backingSlots = 10
      backingType  = "st1"
      backingSize  = 9216
    }
    "160TiB-Hybrid-st1" = {
      slotCount    = 24
      workingSlots = 8
      workingSize  = 1000
      backingSlots = 16
      backingType  = "st1"
      backingSize  = 10240
    }
    "256TiB-Hybrid-st1" = {
      slotCount    = 24
      workingSlots = 8
      workingSize  = 1600
      backingSlots = 16
      backingType  = "st1"
      backingSize  = 16384
    }
    "320TiB-Hybrid-st1" = {
      slotCount    = 25
      workingSlots = 5
      workingSize  = 2500
      backingSlots = 20
      backingType  = "st1"
      backingSize  = 16384
    }
    "8TiB-Hybrid-sc1" = {
      slotCount    = 12
      workingSlots = 4
      workingSize  = 150
      backingSlots = 8
      backingType  = "sc1"
      backingSize  = 1024
    }
    "13TiB-Hybrid-sc1" = {
      slotCount    = 12
      workingSlots = 4
      workingSize  = 175
      backingSlots = 8
      backingType  = "sc1"
      backingSize  = 1664
    }
    "20TB-Hybrid-sc1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 160
      backingSlots = 10
      backingType  = "sc1"
      backingSize  = 2000
    }
    "35TiB-Hybrid-sc1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 350
      backingSlots = 10
      backingType  = "sc1"
      backingSize  = 3584
    }
    "55TiB-Hybrid-sc1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 550
      backingSlots = 10
      backingType  = "sc1"
      backingSize  = 5632
    }
    "90TiB-Hybrid-sc1" = {
      slotCount    = 15
      workingSlots = 5
      workingSize  = 900
      backingSlots = 10
      backingType  = "sc1"
      backingSize  = 9216
    }
    "160TiB-Hybrid-sc1" = {
      slotCount    = 24
      workingSlots = 8
      workingSize  = 1000
      backingSlots = 16
      backingType  = "sc1"
      backingSize  = 10240
    }
    "256TiB-Hybrid-sc1" = {
      slotCount    = 24
      workingSlots = 8
      workingSize  = 1600
      backingSlots = 16
      backingType  = "sc1"
      backingSize  = 16384
    }
    "320TiB-Hybrid-sc1" = {
      slotCount    = 25
      workingSlots = 5
      workingSize  = 2500
      backingSlots = 20
      backingType  = "sc1"
      backingSize  = 16384
    }
    "Use-From-AMI" = {
      slotCount    = 0
      workingSlots = 0
      workingType  = "null"
      workingSize  = 0
      backingSlots = 0
      backingType  = "null"
      backingSize  = 0
    }
  }
}