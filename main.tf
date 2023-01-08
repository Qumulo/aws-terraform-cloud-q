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

# **** Version 4.8 ****

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_vpc" "selected" {
  id = var.aws_vpc_id
}

locals {
  #local variable for cleaner references in subsequent use
  deployment_unique_name = null_resource.name_lock.triggers.deployment_unique_name

  #Paths and S3 prefixes for the provisioning module
  functions_path      = "${path.module}/modules/qprovisioner/functions/"
  functions_s3_prefix = "${var.s3_bucket_prefix}${local.deployment_unique_name}/functions/"
  upgrade_path        = "${path.module}/modules/qprovisioner/upgrade/"
  upgrade_s3_prefix   = "${var.s3_bucket_prefix}${local.deployment_unique_name}/upgrade/"
  scripts_path        = "${path.module}/modules/qprovisioner/scripts/"
  scripts_s3_prefix   = "${var.s3_bucket_prefix}${local.deployment_unique_name}/scripts/"
  state_s3_prefix     = "${var.s3_bucket_prefix}${local.deployment_unique_name}"

  #make lists for subnet IDs
  private_subnet_ids = tolist(split(",", replace(var.private_subnet_id, "/\\s*/", "")))
  public_subnet_ids  = var.public_subnet_id == null ? [] : tolist(split(",", replace(var.public_subnet_id, "/\\s*/", "")))
  nlb_subnet_ids     = var.q_nlb_override_subnet_id == null ? local.private_subnet_ids : tolist(split(",", replace(var.q_nlb_override_subnet_id, "/\\s*/", "")))
}

#Generates a 11 digit random alphanumeric for the deployment_unique_name.  Generated on first apply and never changes.
resource "random_string" "alphanumeric" {
  length    = 11
  lower     = false
  min_upper = 4
  numeric   = true
  special   = false
  upper     = true
  keepers = {
    name = var.deployment_name
  }
  lifecycle { ignore_changes = all }
}

#This  resource is used to 'lock' the deployment_unique_name.  Any changes to the deployment_name after the first apply are ignored.
#Appends the random alpha numeric to the deployment name.  All resources are tagged/named with this unique name.
resource "null_resource" "name_lock" {
  triggers = {
    deployment_unique_name = "${var.deployment_name}-${random_string.alphanumeric.id}"
  }

  lifecycle { ignore_changes = all }
}

#Copy files from the terraform local directory to the specified S3 bucket.  Unique S3 prefix per cluster.  Files will only be updated if the MD5 hash changes.
resource "aws_s3_bucket_object" "provisioner_functions" {
  provider = aws.bucket
  for_each = fileset(local.functions_path, "*")
  bucket   = var.s3_bucket_name
  key      = "${local.functions_s3_prefix}${each.value}"
  source   = "${local.functions_path}${each.value}"
  etag     = filemd5("${local.functions_path}${each.value}")
}

resource "aws_s3_bucket_object" "provisioner_script" {
  provider = aws.bucket
  for_each = fileset(local.scripts_path, "provision.sh")
  bucket   = var.s3_bucket_name
  key      = "${local.scripts_s3_prefix}${each.value}"
  source   = "${local.scripts_path}${each.value}"
  etag     = filemd5("${local.scripts_path}${each.value}")
}

resource "aws_s3_bucket_object" "provisioner_upgrades" {
  provider = aws.bucket
  for_each = fileset(local.upgrade_path, "*")
  bucket   = var.s3_bucket_name
  key      = "${local.upgrade_s3_prefix}${each.value}"
  source   = "${local.upgrade_path}${each.value}"
  etag     = filemd5("${local.upgrade_path}${each.value}")
}

#This sub-module stores Qumulo admin, sidecar and Qumulo software credentials in AWS Secrets Manager.
module "secrets" {
  source = "./modules/secrets"

  cluster_admin_password = var.q_cluster_admin_password
  deployment_unique_name = local.deployment_unique_name
  sidecar_password       = var.q_cluster_admin_password
  sidecar_user_name      = var.q_sidecar_user_name
}

#This sub-module validates and error checks subnets and AZ variables, looks up AWS Marketplace configurations, and establishes the final configuration variables for the cluster.
module "qconfig" {
  source = "./modules/qconfig"

  aws_region             = var.aws_region
  deployment_unique_name = local.deployment_unique_name
  disk_config            = var.q_disk_config
  floating_ips_per_node  = var.q_floating_ips_per_node
  marketplace_type       = var.q_marketplace_type
  max_nodes_down         = 1 #Do not change this
  nlb_subnet_ids         = local.nlb_subnet_ids
  nlb_provision          = var.q_nlb_provision
  node_count             = var.q_node_count
  nodes_per_az           = var.q_nodes_per_az
  private_subnet_ids     = local.private_subnet_ids
  public_subnet_ids      = local.public_subnet_ids
}

#This sub-module looks up the AMI ID based on the marketplace type and the deployment region.
module "qami-id-lookup" {
  count = var.q_marketplace_type == "Specified-AMI-ID" ? 0 : 1

  source = "./modules/qami-id-lookup-5.1.0.1"

  aws_region             = var.aws_region
  marketplace_short_name = module.qconfig.marketplace_short_name
}

#This sub-module builds the Qumulo Cluster consisting of EC2 instances and EBS volumes.
#A security group is built for the cluster and an IAM role is also built for the cluster.
module "qcluster" {
  source = "./modules/qcluster"

  ami_id                    = var.q_marketplace_type == "Specified-AMI-ID" ? var.q_ami_id : module.qami-id-lookup[0].ami_id
  aws_account_id            = data.aws_caller_identity.current.account_id
  aws_number_azs            = module.qconfig.number_azs
  aws_partition             = data.aws_partition.current.partition
  aws_region                = var.aws_region
  aws_vpc_id                = var.aws_vpc_id
  cluster_additional_sg_ids = var.q_cluster_additional_sg_ids == null ? [] : tolist(split(",", replace(var.q_cluster_additional_sg_ids, "/\\s*/", "")))
  cluster_name              = var.q_cluster_name
  cluster_sg_cidrs          = var.q_cluster_additional_sg_cidrs == null ? [data.aws_vpc.selected.cidr_block] : concat([data.aws_vpc.selected.cidr_block], tolist(split(",", replace(var.q_cluster_additional_sg_cidrs, "/\\s*/", ""))))
  deployment_unique_name    = local.deployment_unique_name
  disk_config               = module.qconfig.disk_config
  ec2_key_pair              = var.ec2_key_pair
  flash_iops                = var.q_flash_iops
  flash_tput                = var.q_flash_tput
  flash_type                = var.q_flash_type
  floating_ips_per_node     = module.qconfig.floating_ips_per_node
  instance_recovery_topic   = var.q_instance_recovery_topic
  instance_type             = ((var.q_instance_type == "m5.xlarge" || var.q_instance_type == "m6i.xlarge") && !var.dev_environment) ? replace(var.q_instance_type, "/\\..*/", ".2xlarge") : var.q_instance_type
  kms_key_id                = var.kms_key_id
  node_count                = module.qconfig.node_count
  permissions_boundary      = var.q_permissions_boundary
  private_subnet_ids        = module.qconfig.private_subnet_id_per_node
  require_imdsv2            = true #Supported with 5.1.0.1 AMIs and later
  tags                      = var.tags
  term_protection           = var.term_protection
}

#This sub-module instantiates an EC2 instance for configuration of the Qumulo Cluster and is then shutdown.  
#Floating IPs, Sidecar role and permissions, admin password, and CMK Policy management are all configured.
#Software updates are also automated for the unconfigured instances in the cluster and then quorum is formed.
#Node additions are also supported with this provisioning instance to grow the cluster.
#Until Terraform supports user data updates without destroying the instance, this instance will get destroyed
#and recreated on subsequent applies.  It is built for this as all state is stored in SSM Parameter Store.
module "qprovisioner" {
  source = "./modules/qprovisioner"

  aws_account_id             = data.aws_caller_identity.current.account_id
  aws_number_azs             = module.qconfig.number_azs
  aws_partition              = data.aws_partition.current.partition
  aws_region                 = var.aws_region
  aws_vpc_id                 = var.aws_vpc_id
  check_provisioner_shutdown = var.check_provisioner_shutdown
  cluster_floating_ips       = module.qcluster.floating_ips
  cluster_instance_ids       = module.qcluster.instance_ids
  cluster_max_nodes_down     = module.qconfig.max_nodes_down
  cluster_mod_overness       = module.qconfig.mod_overness
  cluster_name               = var.q_cluster_name
  cluster_node1_ip           = module.qcluster.node1_ip
  cluster_primary_ips        = module.qcluster.primary_ips
  cluster_secrets_arn        = module.secrets.cluster_secrets_arn
  cluster_sg_cidrs           = var.q_cluster_additional_sg_cidrs == null ? [data.aws_vpc.selected.cidr_block] : concat([data.aws_vpc.selected.cidr_block], tolist(split(",", replace(var.q_cluster_additional_sg_cidrs, "/\\s*/", ""))))
  cluster_temporary_password = module.qcluster.temporary_password
  cluster_version            = var.q_cluster_version
  deployment_unique_name     = local.deployment_unique_name
  ec2_key_pair               = var.ec2_key_pair
  flash_type                 = var.q_flash_type
  flash_tput                 = module.qcluster.flash_tput
  flash_iops                 = module.qcluster.flash_iops
  functions_s3_prefix        = local.functions_s3_prefix
  instance_type              = "m5.large"
  kms_key_id                 = var.kms_key_id
  permissions_boundary       = var.q_permissions_boundary
  private_subnet_id          = module.qconfig.private_subnet_id_per_node[0]
  require_imdsv2             = true
  s3_bucket_name             = var.s3_bucket_name
  s3_bucket_region           = var.s3_bucket_region
  scripts_path               = local.scripts_path
  scripts_s3_prefix          = local.scripts_s3_prefix
  sidecar_provision          = var.q_sidecar_provision
  sidecar_secrets_arn        = module.secrets.sidecar_secrets_arn
  software_secrets_arn       = module.secrets.software_secrets_arn
  term_protection            = var.term_protection
  upgrade_s3_prefix          = local.upgrade_s3_prefix

  tags = var.tags
}

#This sub-module provisions the Qumulo Sidecar Lambda functions for EBS volume replacement and CloudWatch metrics.
module "qsidecar" {
  count = var.q_sidecar_provision ? 1 : 0

  source = "./modules/qsidecar"

  cluster_primary_ips           = module.qcluster.primary_ips
  cluster_security_group_id     = module.qcluster.security_group_id
  deployment_unique_name        = local.deployment_unique_name
  sidecar_ebs_replacement_topic = var.q_sidecar_ebs_replacement_topic
  sidecar_password              = var.q_cluster_admin_password
  sidecar_private_subnet_id     = var.q_local_zone_or_outposts ? var.q_sidecar_private_subnet_id : module.qconfig.private_subnet_id_per_node[0]
  sidecar_user_name             = var.q_sidecar_user_name
  sidecar_version               = var.q_sidecar_version

  tags = var.tags
}

#This sub-module builds the Route 53 Private hosted zone with DNS records pointing to floating IPs of the Qumulo EC2 instances.
#This module is not required if an AD domain controller with DNS is in use.  In that case update the AD DNS with the floating
#IPs listed in the main output.
#Likewise this module may be skipped if the floating IPs are added to a different PHZ R53 instance for the VPC.
module "route53-phz" {
  count = var.q_route53_provision && !module.qconfig.multi_az && !var.q_nlb_provision ? 1 : 0

  source = "./modules/route53-phz"

  aws_vpc_id             = var.aws_vpc_id
  cluster_floating_ips   = module.qcluster.floating_ips
  deployment_unique_name = local.deployment_unique_name
  fqdn_name              = var.q_fqdn_name
  record_name            = var.q_record_name == null ? var.q_fqdn_name : var.q_record_name

  tags = var.tags
}

#This module creates resource groups for filtered views of EC2, EBS SSD, and EBS HDD.
#It also creates a log group for Qumulo audit logs and CloudWatch dashboard for the cluster.
module "cloudwatch" {
  source = "./modules/cloudwatch"

  all_flash              = module.qconfig.all_flash
  audit_logging          = var.q_audit_logging
  aws_region             = var.aws_region
  cluster_name           = var.q_cluster_name
  deployment_unique_name = local.deployment_unique_name
  node_names             = join("\",\"", module.qcluster.node_names)

  tags = var.tags
}

#This module creates an AWS NLB in front of the Qumulo cluster for load distribution and fault tolerance.
#Floating IPs are disabled when using this module because DNS is no longer used for load distribution
#and floating IPs are no longer relevant for IP failover.  NLBs cost more $ and NFSv3 locking is not
#reliable through an NLB.  An NLB is optional for single AZ deployments and mandatory for multi-AZ
#deployments.  See the docs.
module "nlb-qumulo" {
  count = var.q_nlb_provision || module.qconfig.multi_az ? 1 : 0

  source = "./modules/nlb-qumulo"

  aws_vpc_id             = var.aws_vpc_id
  cluster_primary_ips    = module.qcluster.primary_ips
  cross_zone             = var.q_nlb_cross_zone
  deployment_unique_name = local.deployment_unique_name
  dereg_delay            = 60
  dereg_term             = false
  node_count             = module.qconfig.node_count
  preserve_ip            = true
  private_subnet_ids     = module.qconfig.nlb_subnet_ids
  proxy_proto_v2         = false
  random_alphanumeric    = random_string.alphanumeric.id
  stickiness             = var.q_nlb_stickiness
  is_public              = var.dev_environment && !var.q_nlb_internal
  term_protection        = var.term_protection

  tags = var.tags
}

#This module creates an AWS NLB in front of the Qumulo cluster in a public subnet for high-availability
#public management connectivity. It is provided for test environments and is not intended for use in
#production environments.  While it only listens on port 443 and 3712 it depends on the inherent DDoS
#protection provided by the AWS NLB, which is just one layer of security.
module "nlb-management" {
  count = var.q_public_mgmt_provision ? 1 : 0

  source = "./modules/nlb-management"

  aws_vpc_id                   = var.aws_vpc_id
  cluster_primary_ips          = module.qcluster.primary_ips
  deployment_unique_name       = local.deployment_unique_name
  node_count                   = module.qconfig.node_count
  public_replication_provision = var.q_public_replication_provision
  public_subnet_ids            = module.qconfig.public_subnet_ids
  random_alphanumeric          = random_string.alphanumeric.id

  tags = var.tags
}
