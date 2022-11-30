 resource "aws_vpc" "test_vpc" {
    cidr_block       = var.main_vpc_cidr
    instance_tenancy = "default"
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
        Name = "aws-terraform-cloud-q-vpc-${var.execution_id}"
    }
 }

 resource "aws_internet_gateway" "igw" {
    vpc_id =  aws_vpc.test_vpc.id
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
    }
 }

 resource "aws_subnet" "publicsubnets" {
    vpc_id =  aws_vpc.test_vpc.id
    cidr_block = "${var.public_subnets}"
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
        Name = "aws-terraform-cloud-q-public-subnet-${var.execution_id}"
    }
 }

 resource "aws_subnet" "privatesubnets" {
    vpc_id =  aws_vpc.test_vpc.id
    cidr_block = "${var.private_subnets}"
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
        Name = "aws-terraform-cloud-q-private-subnet-${var.execution_id}"
    }
 }

 resource "aws_route_table" "publicroutetable" {
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

 resource "aws_route_table" "privateroutetable" {
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

 resource "aws_route_table_association" "publicroutetableassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.publicroutetable.id
 }

 resource "aws_route_table_association" "privateroutetableassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.privateroutetable.id
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
    subnet_id = aws_subnet.publicsubnets.id
    tags = {
        Owner = "aws-terraform-cloud-q-testing"
        Name = "aws-terraform-cloud-q-natgw-${var.execution_id}"
    }
 }