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

output "deployment_unique_name" {
  description = "The unique name for this deployment."
  value       = local.deployment_unique_name
}
output "qumulo_cluster_provisioned" {
  description = "If the qprovisioner module completed secondary provisioning of the cluster = Success/Failure"
  value       = module.qconfig.mod_overness ? "${module.qprovisioner.status} ******REQUIRED: manually increase protection for 2 node failure******" : module.qprovisioner.status
}
output "qumulo_floating_ips" {
  description = "Qumulo floating IPs for IP failover & load distribution.  If using an alternate source for DNS, use these IPs for the A-records."
  value       = module.qcluster.floating_ips
}
output "qumulo_knowledge_base" {
  description = "Qumulo knowledge base"
  value       = "https://care.qumulo.com/hc/en-us/categories/115000637447-KNOWLEDGE-BASE"
}
/*
output "qumulo_primary_ips" {
  description = "Qumulo primary IPs."
  value       = module.qcluster.primary_ips
}
*/
output "qumulo_private_NFS" {
  description = "Private NFS path for the Qumulo cluster"
  value       = var.q_route53_provision ? module.route53-phz[0].nfs : "<custom.dns>:/<NFS Export Name>"
}
output "qumulo_private_SMB" {
  description = "Private SMB UNC path for the Qumulo cluster"
  value       = var.q_route53_provision ? module.route53-phz[0].smb : "\\<custom.dns>\\<SMB Share Name>"
}
output "qumulo_private_url" {
  description = "Private URL for the Qumulo cluster"
  value       = var.q_route53_provision ? module.route53-phz[0].url : "https://<custom.dns>"
}
output "qumulo_private_url_node1" {
  description = "Link to private IP for Qumulo Cluster - Node 1"
  value       = module.qcluster.url
}

#Uncomment any of the submodule outputs below to get all outputs for a given submodule
#None of these outputs should be necessary for production environments

/*
output "outputs_secret_module" {
  value = module.secrets
}
output "outputs_qconfig_module" {
  value = module.qconfig
}
output "outputs_qami-id-lookup_module" {
  value = module.qami-id-lookup
}
output "outputs_qcluster_module" {
  value = module.qcluster
}
output "outputs_route53-phz_module" {
  value = module.route53-phz
}
output "outputs_cloudwatch_module" {
  value = module.cloudwatch
}
*/
