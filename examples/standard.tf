module "qumulo_cloud_q" {
  source = "git::https://github.com/Qumulo/aws-terraform-cloud-q.git?ref=v4.0"

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
  # private_subnet_id                 - Private Subnet to deploy the cluster in
  # term_protection                   - true/false to enable EC2 termination protection.  This should be set to 'true' for production deployments.
  aws_region        = "us-west-2"
  aws_vpc_id        = "vpc-1234567890abcdefg"
  ec2_key_pair      = "my-keypair"
  private_subnet_id = "subnet-1234567890abcdefg"
  term_protection   = true

  # ***** Qumulo Cluster Variables *****
  # q_cluster_admin_password          - Minumum 8 characters and must include one each of: uppercase, lowercase, and a special character
  # q_instance_type                   - >= 5m.2xlarge or >= c5n.4xlarge
  # q_marketplace_type                - The type of AWS Marketplace offer accepted.  Values are:
  #                                       1TB-Usable-All-Flash or 103TB-Usable-All-Flash
  #                                       12TB-Usable-Hybrid-st1, 96TB-Usable-Hybrid-st1, 270TB-Usable-Hybrid-st1, or 809TB-Usable-Hybrid-st1
  #                                       Custom-1TB-6PB or Specified-AMI-ID
  q_cluster_admin_password = "!MyPwd123"
  q_instance_type          = "m5.2xlarge"
  q_marketplace_type       = "1TB-Usable-All-Flash"

  # ***** Qumulo Sidecar Variables *****
  # q_sidecar_version                 - The software verison for the sidecar must match the cluster.  This variable can be used to update the sidecar software version.
  q_sidecar_version = "5.1.0.1"

  # ****************************** Marketplace Type Selection Dependencies ******************************
  # ***** Qumulo Cluster Config Options *****
  # q_disk_config                     - Specify the disk config only if using Marketplace types of 'Custom-' or 'Specified-AMI-ID'  Valid disk configs are:
  #                                       600GiB-AF, 1TB-AF, 5TB-AF, 8TiB-AF, 13TiB-AF, 20TiB-AF, 30TB-AF, 35TiB-AF, 55TiB-AF
  #                                       5TB-Hybrid-st1, 8TiB-Hybrid-st1, 13TiB-Hybrid-st1, 20TB-Hybrid-st1, 35TiB-Hybrid-st1, 55TiB-Hybrid-st1, 90TiB-Hybrid-st1, 160TiB-Hybrid-st1, 256TiB-Hybrid-st1, 320TiB-Hybrid-st1
  #                                       8TiB-Hybrid-sc1, 13TiB-Hybrid-sc1, 20TB-Hybrid-sc1, 35TiB-Hybrid-sc1, 55TiB-Hybrid-sc1, 90TiB-Hybrid-sc1, 160TiB-Hybrid-sc1, 256TiB-Hybrid-sc1, 320TiB-Hybrid-sc1
  # q_node_count                      - Total # EC2 Instances in the cluster (4-20).  Specify if growing the cluster or using Marketplace types of 'Custom-' or 'Specified-AMI-ID'. 0 implies marketplace config lookup.
  q_disk_config = null
  q_node_count  = 0

  # ****************************** Optional **************************************************************
  # ***** Environment and Tag Options *****
  # tags                              - Additional tags to add to all created resources.  Often used for billing, departmental tracking, chargeback, etc.
  #                                     If you add an additional tag with the key 'Name' it will be ignored.  All infrastructure is tagged with the 'Name=deployment_unique_name'.
  #                                        Example: tags = { "key1" = "value1", "key2" = "value2" }
  tags = null
}

output "outputs_qumulo_cloud_q" {
  value = module.qumulo_cloud_q
}