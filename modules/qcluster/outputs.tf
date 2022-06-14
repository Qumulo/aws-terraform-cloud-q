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

output "floating_ips" {
  description = "List of all floating IPs for the Qumulo cluster"
  value       = flatten(concat(aws_instance.node[*].secondary_private_ips))
}
output "instance_ids" {
  description = "List of all EC2 instance IDs for the Qumulo cluster"
  value       = flatten(concat(aws_instance.node[*].id))
}
output "node1_ip" {
  description = "Primary IP for Node 1"
  value       = aws_instance.node[0].private_ip
}
output "node_names" {
  description = "Name tags for nodes (EC2 Instances)"
  value       = concat(aws_instance.node[*].tags.Name)
}
output "placement_group" {
  description = "Placement group create for the Qumulo cluster"
  value       = aws_placement_group.cluster.name
}
output "primary_ips" {
  description = "List of all primary IPs for the Qumulo cluster"
  value       = flatten(concat(aws_instance.node[*].private_ip))
}
output "security_group_id" {
  description = "Security group identifier for Qumulo cluster"
  value       = aws_security_group.cluster.id
}
output "temporary_password" {
  description = "Temporary password for Qumulo cluster.  Used prior to forming first quorum."
  value       = tostring(aws_instance.node[0].id)
}
output "url" {
  description = "Link to node 1 in the cluster"
  value       = "https://${tostring(aws_instance.node[0].private_ip)}"
}
output "temp" {
  description = "value"
  value       = var.private_subnet_ids
}