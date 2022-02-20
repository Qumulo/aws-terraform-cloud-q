[![Qumulo Logo](https://qumulo.com/wp-content/uploads/2021/06/CloudQ-Logo_OnLight.png)](http://qumulo.com)

# aws-terraform-cloud-q
Comprehensive Terraform to deploy a Qumulo cluster with 4 to 20 instances per the AWS Well Architected Framework.
Supports usable capacities from 1TB to 6PB with all Qumulo Core features.

## Requirements

This Terraform deploys Qumulo AMIs with [Qumulo Core Cloud Software](https://qumulo.com/product/cloud-products/) version `>= 4.2.0`
Required Versions:
* [Terraform](https://www.terraform.io/downloads) `>= 1.0.8`
* [AWS Provider](https://github.com/hashicorp/terraform-provider-aws) `>= 3.7`
* [HashiCorp/Random](https://github.com/hashicorp/terraform-provider-random) `>= 3.1`
* [HashiCorp/Null](https://github.com/hashicorp/terraform-provider-null) `>= 3.1`

A subscription to an [AWS Marketplace](https://aws.amazon.com/marketplace/search/results?x=0&y=0&searchTerms=qumulo) Qumulo offer is required.
For private offers via the AWS Marketplace contact [Qumulo Sales](http://discover.qumulo.com/cloud-calc-contact.html).

## Usage

**IMPORTANT:** When cloning this repository specify the tagged release version because there may be breaking changes between releases. Example: git clone <repo_url> --branch <tag_name> --single-branch

Reference Architecture:
![Ref Arch](./docs/qumulo-cloud-q-architecture_diagram.png)

### Pre-Deployment Docs
For help planning the deployment see the table of documents below.

|Documentation |Description|
|[DNS options in AWS: IP failover & client distribution](https://qumulo.com/resources/qumulo-dns-options-in-aws/) | Details on the DNS options in AWS.|
|[Terraform: Supported AWS Regions](./docs/tf-supported-regions.pdf) | Details on supported AWS Regions for Cloud Q with Terraform.|
|[Terraform: Deploying in a VPC with no internet access](./docs/tf-deploying-without-inet.pdf) | Details on deploying with Terraform into a VPC that has no internet access.|
|[Terraform: Deploying using an AWS Custom IAM role](./docs/tf-deploying-with-custom-iam-role.pdf) | Details on deploying with Terraform using a custom IAM role.|
|[Terraform: AWS resources & EBS Service Quota planning](./docs/tf-resources-ebs-quota-planning.pdf) | Details on service-quota planning for Amazon EBS, including EC2 instance types and EBS volume types.|
|[Terraform: Qumulo sizing & performance on AWS](./docs/tf-qumulo-sizing-performance.pdf) | Details on Qumulo cluster performance and scalability on AWS.|
|===

### Terraform Guidance
There are a multitude of Terraform workflows from those that just use a default local workspace to those using Terraform Cloud with remote state.  The very first variable in the .tfvars files provided is 'deployment_name'.  Some users may choose to make this the workspace name.  Other users may want the same deployment name in multiple workspaces. Regardless, a 'deployment_unique_name' is generated that consists of the deployment name appended with an 11 digit random alphanumeric.  All resources are tagged with the 'deployment_unique_name' and the 'deployment_name' is the keeper for the random alphanumeric.  The 'deployment_unique_name' will never change on subsequent Terraform applies as long as the 'deployment_name' is left unchanged as recommended.  No matter your naming convention or how you choose to use Terraform, you will have your chosen name and uniquely named resources so no conflicts occur between NLBs, resource groups, cross-regional CloudWatch views, etc.
**IMPORTANT:** If you are spinning up multiple clusters, create unique .tfvar files for them and at an absolute minimum define a unique value for the 'q_cluster_name' variable.  If using the optional Route53 PHZ, also define a unique value for 'q_fqdn_name' for each cluster.

### Inputs
Select between the minimalist standard.tfvars or the fully featured advanced.tfvars.  Terraform.tfvars is a copy of advanced.tfvars in this repository. These files all have extensive comments providing guidance on each variable.  The standard version makes many decisions for you to simplify the input process and deploy a Qumulo cluster with the software version of the Qumulo AMI.  The advanced version provides the flexibility that most production environments will require, as seen in the table below.

|  | standard.tvfars | advanced.tvfars |
|------|-------------|-------------|
| Deploy in a Local Zone || ✅ |
| Deploy on Outposts || ✅ |
| Deploy with a Custom AMI-ID || ✅ |
| Customize Qumulo Admin Password | ✅ | ✅ |
| Customize EC2 Instance Type | ✅ | ✅ |
| Customize EC2 Instance Count | ✅ | ✅ |
| Cuustomize Termination Protection | ✅ | ✅ |
| Customize Qumulo Cluster Name || ✅ |
| Customize Qumulo Software Version || ✅ |
| Customize Qumulo Sidecar Deployment || ✅ |
| Customize Qumulo # of Floating IPs || ✅ |
| Optional: Add SNS Topics for EC2 & EBS Recovery || ✅ |
| Optional: Add R53 PHZ DNS for Floating IPs || ✅ |
| Optional: Add CIDRS to Qumulo Seciruty Group || ✅ |
| Optional: Add Qumulo Public Management || ✅ |
| Optional: Add Qumulo Public Replication Port || ✅ |
| Optional: Enable CloudWatch Audit Log Messages || ✅ |
| Optional: Apply KMS CMK for EBS Encryption || ✅ |
| Optional: Set IAM Permissions Boundary || ✅ |
| Optional: Set Environment Type || ✅ |

### Outputs

| Name | Description |
|------|-------------|
| deployment_unique_name | The deployment_name with an appended 11 digit random alphanumeric |
| qumulo_cluster_provisioned | Secondary provisioning of the cluster completed: Success/Failure |
| qumulo_floating_ips | List of the floating IPs for the cluster |
| qumulo_knowledge_base | Link to the Qumulo knowledge base |
| qumulo_private_NFS | Private NFS path for the Qumulo cluster |
| qumulo_private_SMB | Private SMB UNC path for the Qumulo cluster |
| qumulo_private_url | Private URL for the Qumulo cluster |
| qumulo_private_url_node1 | Private URL for the Qumulo cluster |
| qumulo_private_NFS | Link to the private IP for Qumulo cluster node 1 |

### Post-Deployment Docs
If you're using Qumulo Core version 4.3.0 or newer, you can populate data on your Qumulo cluster by copying data from an Amazon S3 bucket using [Qumulo Shift for Amazon S3](https://qumulo.com/wp-content/uploads/2020/06/ShiftForAWS_DataSheet.pdf).

For more information on Qumulo SHIFT, custom CloudWatch Dashboards, adding nodes, the provisioning instance, and destroying the cluster see the documents in the table below.

|Documentation |Description|
|[Qumulo SHIFT: Copy from Amazon S3](https://github.com/Qumulo/docs/blob/gh-pages/shift-from-s3.md)| Copy data from S3 with the Qumulo GUI/CLI/API. |
|[Qumulo SHIFT: Copy to Amazon S3](https://github.com/Qumulo/docs/blob/gh-pages/shift-to-s3.md)| Copy data to S3 with the Qumulo GUI/CLI/API. |
|[Terraform: Using the Custom CloudWatch Dashboard](./docs/tf-cloudwatch-dashboard.pdf)| Details on viewing the CloudWatch dashboard and resource groups that are created for the Qumulo cluster.|
|[Terraform: Supported Updates](./docs/tf-update-deployment.pdf)| Details on Terraform update options and examples, including adding instances (nodes) to the cluster and upgrading the Qumulo Sidecar.|
|[Terraform: Provisioning Instance Functions](./docs/tf-provisioning-instance-functions.pdf)| Details on the functions of the provisioner instance.|
|[Terraform: Destroying the Cluster](./docs/tf-destroy-deployment.pdf)| Details on backing up data, termination protection, and on cleaning up an AWS KMS customer managed key policy. |

## Help

Please post all feedback via the AWS GitHub repository feedback link.

__Note:__ This project is provided as a public service to the AWS/Terraform
community and is not directly supported by Qumulo's paid enterprise support. It is
intended to be used by expert users only.

## Copyright

Copyright © 2022 [Qumulo, Inc.](https://qumulo.com)

## License

[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)

See [LICENSE](LICENSE) for full details

    MIT License
    
    Copyright (c) 2022 Qumulo, Inc.
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.

### Contributors

 - [Dack Busch](https://github.com/dackbusch)
 - [Gokul Kupparaj](https://github.com/gokulku)
