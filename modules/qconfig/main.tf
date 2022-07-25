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

data "aws_subnet" "private_subnet_ids_map" {
  for_each = toset(var.private_subnet_ids)

  id = each.key
}
data "aws_subnet" "public_subnet_ids_map" {
  for_each = toset(var.public_subnet_ids)

  id = each.key
}

data "aws_ssm_parameter" "max-nodes-down" {
  name = "/qumulo/${var.deployment_unique_name}/max-nodes-down"

  depends_on = [aws_ssm_parameter.max-nodes-down]
}

locals {
  #Find the number of AZs desired
  number_azs     = length(var.private_subnet_ids)
  number_pub_azs = var.public_subnet_ids == null ? 0 : length(var.public_subnet_ids)
  maz            = local.number_azs > 1
  saz            = !local.maz

  #Multi-AZ validation
  valid_4_maz_region = local.saz || local.number_azs == 5 || (local.number_azs == 4 && (var.aws_region == "us-west-2" || var.aws_region == "us-east-1" || var.aws_region == "ap-northeast-2"))
  valid_5_maz_region = local.saz || local.number_azs == 4 || (local.number_azs == 5 && (var.aws_region == "us-east-1"))

  valid_number_azs     = local.number_azs == 1 || local.number_azs == 4 || local.number_azs == 5
  valid_number_pub_azs = local.number_pub_azs == 0 || local.number_azs == local.number_pub_azs
  valid_4_maz_mp_type  = local.saz || local.number_azs == 5 || (local.number_azs == 4 && lookup(var.marketplace_map[var.marketplace_type], "MAZ4"))
  valid_5_maz_mp_type  = local.saz || local.number_azs == 4 || (local.number_azs == 5 && lookup(var.marketplace_map[var.marketplace_type], "MAZ5"))
  invalid_disk_config  = var.disk_config == null && (var.marketplace_type == "Specified-AMI-ID" || var.marketplace_type == "Custom-1TB-6PB")

  #Marketplace lookups
  marketplace_short_name = lookup(var.marketplace_map[var.marketplace_type], "ShortName")
  total_node_count       = local.maz ? local.number_azs * var.nodes_per_az : var.node_count
  node_count             = var.marketplace_type == "Specified-AMI-ID" || var.marketplace_type == "Custom-1TB-6PB" || local.total_node_count != 0 ? local.total_node_count : lookup(var.marketplace_map[var.marketplace_type], "NodeCount")
  disk_config            = var.marketplace_type == "Specified-AMI-ID" || var.marketplace_type == "Custom-1TB-6PB" ? var.disk_config : lookup(var.marketplace_map[var.marketplace_type], "DiskConfig")
  all_flash              = local.disk_config == null ? "" : element(split("-", local.disk_config), 1)

  #Modify overness if growing from 1 to 2 nodes per AZ.  All other node per AZ changes are invalid.
  current_max_nodes_down = nonsensitive(data.aws_ssm_parameter.max-nodes-down.value) == "null" ? 0 : tonumber(nonsensitive(data.aws_ssm_parameter.max-nodes-down.value))
  mod_overness_no        = local.current_max_nodes_down == 0 || local.current_max_nodes_down == var.nodes_per_az
  mod_overness           = local.current_max_nodes_down == 1 && var.nodes_per_az == 2

  #Validate max_nodes_down
  valid_max_nodes_down  = var.max_nodes_down == 1 && local.node_count > 3 || var.max_nodes_down == 2 && local.node_count > 7 || var.max_nodes_down == 3 && local.node_count > 10 || var.max_nodes_down == 4 && local.node_count > 23
  max_nodes_down        = local.saz ? var.max_nodes_down : var.nodes_per_az
  floating_ips_per_node = local.saz ? var.floating_ips_per_node : 0

  #swap the key to the AZ name and the map will sort based on the AZ name
  private_azs_map = {
    for v in data.aws_subnet.private_subnet_ids_map : v.availability_zone => v.id...
  }
  public_azs_map = {
    for v in data.aws_subnet.public_subnet_ids_map : v.availability_zone => v.id...
  }

  #get the private AZ IDs to check for us-east-1 invalid AZ
  private_az_ids = [
    for v in data.aws_subnet.private_subnet_ids_map : v.availability_zone_id
  ]
  invalid_us_east_az_ids = contains(local.private_az_ids, "use1-az3")

  #get the subnet IDs
  private_subnet_id_per_az = [
    for v in local.private_azs_map : v[0]
  ]
  public_subnet_id_per_az = [
    for v in local.public_azs_map : v[0]
  ]

  #build the full list of subnet IDs for every node, keeping order
  private_subnet_id_per_node = local.maz ? flatten([
    for i in range(var.nodes_per_az) :
    local.private_subnet_id_per_az
    ]) : flatten([
    for i in range(local.node_count) :
    local.private_subnet_id_per_az
  ])

  #get the AZs
  private_azs = [
    for k, v in local.private_azs_map : k
  ]
  public_azs = [
    for k, v in local.public_azs_map : k
  ]
  unique_azs     = length(local.private_azs) == local.number_azs
  unique_pub_azs = length(local.public_azs) == local.number_pub_azs
}

#Create parameter stores for syncing state between the config module and the provisioner instance
resource "aws_ssm_parameter" "creation-number-AZs" {
  name  = "/qumulo/${var.deployment_unique_name}/creation-number-AZs"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "max-nodes-down" {
  name  = "/qumulo/${var.deployment_unique_name}/max-nodes-down"
  type  = "String"
  value = "null"
  lifecycle { ignore_changes = [value] }
}

#Error checking null-resources
resource "null_resource" "check_valid_disk_config" {
  count = !local.invalid_disk_config ? 0 : "Disk config cannot be null when selecting Marketplace Types = Specified-AMI-ID or Custom-1TB-6PB"
}
resource "null_resource" "check_valid_number_azs" {
  count = local.valid_number_azs ? 0 : "Invalid number of private subnet IDs.  Specify 1 private subnet ID for a single AZ deployment.  Specify 4 or 5 private subnet IDs for a multi-AZ deployment."
}
resource "null_resource" "check_valid_number_pub_azs" {
  count = local.valid_number_pub_azs ? 0 : "var.q_public_management_provision = true and the number of public subnet IDs doesn't match the number of private subnet IDs."
}
resource "null_resource" "check_valid_4_maz_mp_type" {
  count = local.valid_4_maz_mp_type ? 0 : "Invalid Marketplace type for a 4xAZ deployment. 1TB-Usable-All-Flash, 12TB-Usable-Hybrid-st1, Custom-1TB-6PB, or Specified-AMI-ID are supported."
}
resource "null_resource" "check_valid_5_maz_mp_type" {
  count = local.valid_5_maz_mp_type ? 0 : "Invalid Marketplace type for a 5xAZ deployment. 103TB-Usable-All-Flash, Custom-1TB-6PB, or Specified-AMI-ID are supported."
}
resource "null_resource" "check_valid_4_maz_region" {
  count = local.valid_4_maz_region ? 0 : "Invalid multi-AZ region. 4 AZ regions: us-west-2, us-east-1, ap-northeast-1, ap-northeast-2."
}
resource "null_resource" "check_valid_5_maz_region" {
  count = local.valid_5_maz_region ? 0 : "Invalid multi-AZ region. 5 AZ region: us-east-1."
}
resource "null_resource" "check_unique_azs" {
  count = local.unique_azs ? 0 : "Two or more of the private subnet IDs provided are in the same AZ."
}
resource "null_resource" "check_invalid_us_east_az_ids" {
  count = !local.invalid_us_east_az_ids ? 0 : "AWS us-east-1 AZ ID = use1-az3 does not support Qumulo required EC2 instance types."
}
resource "null_resource" "check_max_nodes_down" {
  count = local.valid_max_nodes_down ? 0 : "The number of nodes in the cluster isn't large enough to support the desired max_nodes_down.  Minimum cluster size -> max_nodes_down: 4->1, 8->2, 11->3, 24->4."
}