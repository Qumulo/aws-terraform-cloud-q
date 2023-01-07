# ****************************** Required *************************************************************
# ***** Terraform Variables *****
# deployment_name                   - Any <=32 character name for the deployment. Set on first apply.  Changes are ignoreed after that to prevent unintended resource distruction. 
#                                   - All infrastructure will be tagged with the Deployment Name and a unique 11 digit alphanumeric suffix.
deployment_name = "my-deployment-name"

# ***** S3 Bucket Variables *****
# s3_bucket_name                    - S3 Bucket to place provisioning instance files in
# s3_bucket_prefix                  - S3 prefix, a folder. A subfolder with the deployment name is created under the supplied prefix
# s3_bucket_region                  - Region the S3 bucket is hosted in
s3_bucket_name   = "my-bucket"
s3_bucket_prefix = "my-prefix/"
s3_bucket_region = "us-west-2"

# ***** AWS Variables *****
# aws_region                        - Region for the deployment of the cluster
# aws_vpc_id                        - The VPC for the deployment within the provided region
# ec2_keypair                       - EC2 key pair within the region
# private_subnet_id                 - Private Subnet to deploy the cluster in, or a comma delimited list with four subnets if deploying a multi-AZ distributed cluster
#                                       Note: Distributed multi-AZ deployments are only supported in regions with at least 4 AZs: us-west-2, us-east-1, and ap-northeast-2.
# term_protection                   - true/false to enable EC2 termination protection.  This should be set to 'true' for production deployments.
aws_region        = "us-west-2"
aws_vpc_id        = "vpc-1234567890abcdefg"
ec2_key_pair      = "my-keypair"
private_subnet_id = "subnet-1234567890abcdefg"
term_protection   = true

# ***** Qumulo Cluster Variables *****
# q_cluster_admin_password          - Minumum 8 characters and must include one each of: uppercase, lowercase, and a special character
# q_cluster_name                    - Name must be an alpha-numeric string between 2 and 15 characters. Dash (-) is allowed if not the first or last character. Must be unique per cluster.
# q_cluster_version                 - Software version for creation >= 5.1.0.1.  This variable MAY NOT BE USED to update the cluster software after creation.  Use the Qumulo UI instead.
# q_instance_type                   - >= m5.2xlarge, >= m6i.2xlarge, or >= c5n.4xlarge. To use m5.xlarge set the optional variable dev_environment=true
# q_marketplace_type                - The type of AWS Marketplace offer accepted.  Values are:
#                                       1TB-Usable-All-Flash or 103TB-Usable-All-Flash
#                                       12TB-Usable-Hybrid-st1, 96TB-Usable-Hybrid-st1, 270TB-Usable-Hybrid-st1, or 809TB-Usable-Hybrid-st1
#                                       Custom-1TB-6PB or Specified-AMI-ID
q_cluster_admin_password = "!MyPwd123"
q_cluster_name           = "Cloud-Q"
q_cluster_version        = "5.2.5"
q_instance_type          = "m5.2xlarge"
q_marketplace_type       = "1TB-Usable-All-Flash"

# ***** Qumulo Sidecar Variables *****
# q_local_zone_or_outposts          - true if deploying the cluster in a local zone or on Outposts.
# q_sidecar_private_subnet_id       - Subnet in the Parent Region for the Sidecar Lambdas if deploying in a local zone or on Outposts.  
# q_sidecar_provision               - true to deploy the Sidecar Lambdas.  
# q_sidecar_version                 - The software verison for the sidecar must match the cluster.  This variable can be used to update the sidecar software version.
q_local_zone_or_outposts    = false
q_sidecar_private_subnet_id = null
q_sidecar_provision         = false
q_sidecar_version           = "5.2.5"

# ****************************** Marketplace Type Selection Dependencies ******************************
# ***** Qumulo Cluster Config Options *****
# q_ami_id                          - This ami-id is only used if 'q_marketplace_type' is set to 'Specified-AMI-ID' above
# q_disk_config                     - Specify the disk config only if using Marketplace types of 'Custom-' or 'Specified-AMI-ID'  Valid disk configs are:
#                                       600GiB-AF, 1TB-AF, 5TB-AF, 8TiB-AF, 13TiB-AF, 20TiB-AF, 30TB-AF, 35TiB-AF, 55TiB-AF
#                                       5TB-Hybrid-st1, 8TiB-Hybrid-st1, 13TiB-Hybrid-st1, 20TB-Hybrid-st1, 35TiB-Hybrid-st1, 55TiB-Hybrid-st1, 90TiB-Hybrid-st1, 160TiB-Hybrid-st1, 256TiB-Hybrid-st1, 320TiB-Hybrid-st1
#                                       8TiB-Hybrid-sc1, 13TiB-Hybrid-sc1, 20TB-Hybrid-sc1, 35TiB-Hybrid-sc1, 55TiB-Hybrid-sc1, 90TiB-Hybrid-sc1, 160TiB-Hybrid-sc1, 256TiB-Hybrid-sc1, 320TiB-Hybrid-sc1
# q_flash_type                      - Specify gp2 or gp3.  Default is gp3.  
# q_flash_tput                      - Specify gp3 throughput in MB/s 125 to 1000. Default is 250.  Not applicable to gp2.
# q_flash_iops                      - Specify gp3 iops between 3000 to 16000.  Default is 3000.  Not applicable to gp2.
# q_node_count                      - Single AZ only & ignored for multi-AZ.  Total # EC2 Instances in the cluster (4-20).  Specify if growing the cluster or using Marketplace types of 'Custom-' or 'Specified-AMI-ID'. 0 implies marketplace config lookup.
# q_nodes_per_az                    - Multi AZ only & ignored for single AZ.  Must be specified for distributed multi-AZ deployments with 1, 2, or 3.
q_ami_id       = null
q_disk_config  = null
q_flash_type   = "gp3"
q_flash_tput   = 250
q_flash_iops   = 3000
q_node_count   = 0
q_nodes_per_az = 0

# ****************************** Optional **************************************************************
# ***** Environment and Tag Options *****
# check_provisioner_shutdown        - Default is true.  Launches a local-exec script on the Terraform machine to validate the completion of secondary provisioning of the cluster.
# dev_environment                   - Set to true to enable the use of m5.xlarge instance types.  NOT recommended for production.
# tags                              - Additional tags to add to all created resources.  Often used for billing, departmental tracking, chargeback, etc.
#                                     If you add an additional tag with the key 'Name' it will be ignored.  All infrastructure is tagged with the 'Name=deployment_unique_name'.
#                                        Example: tags = { "key1" = "value1", "key2" = "value2" }
check_provisioner_shutdown = true
dev_environment            = false
tags                       = null

# ***** Qumulo Cluster Misc Options *****
# kms_key_id                        - Specify a KMS Customer Managed Key ID for EBS Volume Encryption. Otherwise an AWS default key will be used.
# q_audit_logging                   - Set true to enable audit logging to CloudWatch logs
# q_cluster_additional_sg_cidrs     - Comma delimited list of CIDRS to add to the Qumulo Cluster security group. 10.10.10.0/24, 10.11.30.0/24, etc
# q_cluster_additional_sg_ids       - Comma delimited list of optional security group Ids to add to the Qumulo Cluster. sg-0123456789abcdefg, sg-abcdefg0123456789, etc
# q_floating_ips_per_node           - An integer value from 1 to 4 for IP failover protection and client distribution with DNS. Set to 0 if deploying nlb-qumulo module.
# q_permissions_boundary            - Apply an IAM permission boundary policy to all created IAM roles. Policy Name not ARN.
kms_key_id                    = null
q_audit_logging               = false
q_cluster_additional_sg_cidrs = null
q_cluster_additional_sg_ids   = null
q_floating_ips_per_node       = 3
q_permissions_boundary        = null

# ***** SNS Options *****
# q_instance_recovery_topic         - Specify the SNS arn
# q_sidecar_ebs_replacement_topic   - Specify the SNS arn
q_instance_recovery_topic       = null
q_sidecar_ebs_replacement_topic = null

# ***** OPTIONAL module 'rout53-phz' *****
# q_fqdn_name                       - Specify an FQDN like companyname.local, for example
# q_record_name                     - The Record Name prefix should be specified if you plan to mix other records in the PHZ
# q_route53_provision               - true/false to provision the R53 PHZ
q_fqdn_name         = "my-dns-name.local"
q_record_name       = "qumulo"
q_route53_provision = false

# ***** OPTIONAL module 'nlb-qumulo' *****
# ----- Disables any R53 provisioning, disables floating IPs, used for multi-AZ deployments or single AZ deployments that require PrivateLink
# q_nlb_cross_zone                  - true/false to enable cross AZ load balancing.  Only relevant for multi-AZ deployments.
# q_nlb_override_subnet_id          - Default = null.  If q_nlb_provision = true, the NLB will be deployed in the same subnet(s) as the cluster.
#                                       To override enter a Private Subnet to deploy the NLB in, or a comma delimited list with four subnets if deploying a multi-AZ distributed cluster
#                                       Note: Distributed multi-AZ deployments are only supported in regions with at least 4 AZs: us-west-2, us-east-1, and ap-northeast-2.
# q_nlb_provision                   - true/false to enable deployment of the NLB.  If the qconfig module senses multi-AZ it will deploy the NLB in the same subnets as the cluster
# q_nlb_stickiness                  - true/false to enable sticky sessions
q_nlb_cross_zone         = false
q_nlb_override_subnet_id = null
q_nlb_provision          = false
q_nlb_stickiness         = true

# ***** OPTIONAL module 'nlb-management' *****
# ----- Deploys an NLB in a public subnet for public management reachability.  Test environments only.  Not for production.
# public_subnet_id                  - AWS public subnet ID(s), one for single AZ, 4 or more for multi-AZ as a comma delimited string
# q_public_mgmt_provision           - true/false to enable deployment of the management NLB
# q_public_replication_provision    - true/false to enable Qumulo replication port
public_subnet_id               = null
q_public_mgmt_provision        = false
q_public_replication_provision = true