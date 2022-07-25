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

variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "deployment_unique_name" {
  description = "Unique Name for this Terraform deployment.  This is the deployment name plus 12 random hex digits that will be used for all resource names where appropriate."
  type        = string
}
variable "disk_config" {
  description = "Qumulo disk config"
  type        = string
}
variable "floating_ips_per_node" {
  description = "Qumulo floating IP addresses per node"
  type        = number
}
variable "marketplace_type" {
  description = "Qumulo AWS marketplace type"
  type        = string
}
variable "max_nodes_down" {
  description = "Maximum number of nodes that may be offline with full cluster functionality"
  type        = number
}
variable "node_count" {
  description = "Qumulo cluster node count"
  type        = number
}
variable "nodes_per_az" {
  description = "IGNORE: For Future Use - Qumulo nodes per AZ."
  type        = number
}
variable "private_subnet_ids" {
  description = "AWS private subnet identifiers"
  type        = list(string)
}
variable "public_subnet_ids" {
  description = "AWS public subnet identifiers"
  type        = list(string)
}
variable "marketplace_map" {
  description = "Qumulo marketplace selection mapped to disk config, node count, and short name"
  type = map(object({
    DiskConfig = string
    NodeCount  = number
    ShortName  = string
    MAZ4       = bool
    MAZ5       = bool
  }))
  default = {
    "1TB-Usable-All-Flash" = {
      DiskConfig = "600GiB-AF"
      NodeCount  = 4
      ShortName  = "1TB"
      MAZ4       = true
      MAZ5       = false
    }
    "12TB-Usable-Hybrid-st1" = {
      DiskConfig = "5TB-Hybrid-st1"
      NodeCount  = 4
      ShortName  = "12TB"
      MAZ4       = true
      MAZ5       = false
    }
    "96TB-Usable-Hybrid-st1" = {
      DiskConfig = "20TB-Hybrid-st1"
      NodeCount  = 6
      ShortName  = "96TB"
      MAZ4       = false
      MAZ5       = false
    }
    "103TB-Usable-All-Flash" = {
      DiskConfig = "30TB-AF"
      NodeCount  = 5
      ShortName  = "103TB"
      MAZ4       = false
      MAZ5       = true
    }
    "270TB-Usable-Hybrid-st1" = {
      DiskConfig = "55TiB-Hybrid-st1"
      NodeCount  = "6"
      ShortName  = "270TB"
      MAZ4       = false
      MAZ5       = false
    }
    "809TB-Usable-Hybrid-st1" = {
      DiskConfig = "160TiB-Hybrid-st1"
      NodeCount  = 6
      ShortName  = "809TB"
      MAZ4       = false
      MAZ5       = false
    }
    "Custom-1TB-6PB" = {
      DiskConfig = "CUSTOM-ERROR-NEED-TO-SELECT-DISK-CONFIG"
      NodeCount  = 0
      ShortName  = "Custom"
      MAZ4       = true
      MAZ5       = true
    }
    "Specified-AMI-ID" = {
      DiskConfig = "SPECIFIED-AMI-ID-ERROR-NEED-TO-SELECT-DISK-CONFIG"
      NodeCount  = 0
      ShortName  = "Custom"
      MAZ4       = true
      MAZ5       = true
    }
  }
}