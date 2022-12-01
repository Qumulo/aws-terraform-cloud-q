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

#     ___        ______
#    / \ \      / / ___|
#   / _ \ \ /\ / /\___ \
#  / ___ \ V  V /  ___) |
# /_/   \_\_/\_/  |____/
#  FIGLET: AWS
#

resource "aws_vpc" "test_vpc" {
   cidr_block           = cidrsubnet(var.vpc_cidr, 0, 0)
   instance_tenancy = "default"
   tags = {
      Owner = "aws-terraform-cloud-q-testing"
      Name = "aws-terraform-cloud-q-vpc-${var.execution_id}"
   }
}

resource "aws_subnet" "private" {
  count  = length(var.private_azs)
  vpc_id = aws_vpc.test_vpc.id
  # the second parameter to cidrsubnet is the additional bits (so base 2) to add to the / to make the subnet ip range smaller
  # e.g., by specifying 2, /20 will become /22 which will give 4 subnets, 3 will make /20 into /23, which will give 8 subnets
  # Note, we need the number of subnets >= length(var.private_azs) + length(var.public_azs)
  cidr_block        = cidrsubnet(aws_vpc.test_vpc.cidr_block, 2, count.index)
  availability_zone = var.private_azs[count.index]
  tags = {
      Owner = "aws-terraform-cloud-q-testing"
      Name = "aws-terraform-cloud-q-private-subnet-${var.execution_id}"
  }
}

resource "aws_subnet" "public" {
  count  = length(var.public_azs)
  vpc_id = aws_vpc.test_vpc.id
  # by using length(var.private_azs) we are putting these after the private subnets.
  cidr_block        = cidrsubnet(aws_vpc.test_vpc.cidr_block, 2, length(var.private_azs) + count.index)
  availability_zone = var.public_azs[count.index]
  tags = {
      Owner = "aws-terraform-cloud-q-testing"
      Name = "aws-terraform-cloud-q-public-subnet-${var.execution_id}"
  }
}

 resource "aws_internet_gateway" "igw" {
    vpc_id =  aws_vpc.test_vpc.id
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
    }
 }

 resource "aws_route_table" "public_routetable" {
    vpc_id =  aws_vpc.test_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
     }
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
        Name = "aws-terraform-cloud-q-public-rt-${var.execution_id}"
    }
 }

 resource "aws_route_table" "private_routetable" {
    vpc_id = aws_vpc.test_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
        Name = "aws-terraform-cloud-q-private-rt-${var.execution_id}"
    }
 }

 resource "aws_route_table_association" "public_route_table_association" {
   count          = length(var.public_azs)
   subnet_id      = aws_subnet.public[count.index].id
   route_table_id = aws_route_table.public_routetable.id
 }

 resource "aws_route_table_association" "private_route_table_association" {
   count          = length(var.private_azs)
   subnet_id      = aws_subnet.private[count.index].id
   route_table_id = aws_route_table.private_routetable.id
 }

 resource "aws_eip" "eip1" {
    vpc   = true
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
        Name = "aws-terraform-cloud-q-eip-${var.execution_id}"
    }
 }

 resource "aws_nat_gateway" "natgw" {
   allocation_id = aws_eip.eip1.id
   subnet_id     = length(var.public_azs) > 0 ? aws_subnet.public[0].id : aws_subnet.private[0].id
   tags = {
      Owner = "aws-terraform-cloud-q-testing"
      Name = "aws-terraform-cloud-q-natgw-${var.execution_id}"
   }
 }