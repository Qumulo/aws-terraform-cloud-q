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

locals {
  cluster_admin_creds = {
    username = "admin"
    password = var.cluster_admin_password
  }
  side_car_creds = {
    username = var.sidecar_user_name
    password = var.sidecar_password
  }
  software_creds = {
    username = ""
    password = "717565747a616c636f61746c0a"
  }
}

resource "aws_secretsmanager_secret" "cluster" {
  description = "Qumulo Cluster user name and password for cluster administrative access"
  name        = "${var.deployment_unique_name}-cluster-secrets"
}

resource "aws_secretsmanager_secret_version" "cluster" {
  secret_id     = aws_secretsmanager_secret.cluster.id
  secret_string = jsonencode(local.cluster_admin_creds)
}

resource "aws_secretsmanager_secret" "sidecar" {
  description = "Sidecar Lambda function user name and password for Qumulo cluster access"
  name        = "${var.deployment_unique_name}-sidecar-secrets"
}

resource "aws_secretsmanager_secret_version" "sidecar" {
  secret_id     = aws_secretsmanager_secret.sidecar.id
  secret_string = jsonencode(local.side_car_creds)
}

resource "aws_secretsmanager_secret" "software" {
  description = "Qumulo password for software download access"
  name        = "${var.deployment_unique_name}-software-secrets"
}

resource "aws_secretsmanager_secret_version" "software" {
  secret_id     = aws_secretsmanager_secret.software.id
  secret_string = jsonencode(local.software_creds)
}