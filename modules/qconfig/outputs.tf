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

output "all_flash" {
  description = "AF = All Flash Disk Config"
  value       = local.all_flash
}
output "disk_config" {
  description = "Qumulo node disk config"
  value       = local.disk_config
}
output "floating_ips_per_node" {
  description = "Qumulo floating IP addresses per node"
  value       = local.floating_ips_per_node
}
output "marketplace_short_name" {
  description = "Abreviated name for Qumulo Marketplace Type"
  value       = local.marketplace_short_name
}
output "current_max_nodes_down" {
  description = "Maximum nodes that can be down and the cluster remain functional"
  value       = local.current_max_nodes_down
}
output "max_nodes_down" {
  description = "Maximum nodes that can be down and the cluster remain functional"
  value       = local.max_nodes_down
}
output "mod_overness" {
  description = "Modifiy overness for 2 node cluster level protection"
  value       = local.mod_overness
}
output "multi_az" {
  description = "Multi-AZ Deployment"
  value       = local.maz
}
output "nlb_subnet_ids" {
  description = "Validated and sorted nlb subnets IDs"
  value       = local.nlb_subnet_id_per_az
}
output "node_count" {
  description = "Qumulo cluster final node count"
  value       = local.node_count
}
output "number_azs" {
  description = "Number of AZs to deploy the cluster in"
  value       = local.number_azs
}
output "original_subnet_ids" {
  description = "CLEANUP"
  value       = var.private_subnet_ids
}
output "private_subnet_id_per_node" {
  description = "Validated and sorted private subnets ID for each node"
  value       = local.private_subnet_id_per_node
}
output "private_azs_map" {
  description = "Validated and sorted private AZ Map"
  value       = local.private_azs_map
}
output "private_subnet_ids" {
  description = "Validated and sorted private subnets IDs"
  value       = local.private_subnet_id_per_az
}
output "public_subnet_ids" {
  description = "Validated and sorted public subnets IDs"
  value       = local.public_subnet_id_per_az
}