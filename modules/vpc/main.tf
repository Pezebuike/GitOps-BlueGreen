terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"  # Or whatever version you're aiming to use
    }
  }
}

provider "aws" {
  region = var.region
}
# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC resource
resource "aws_vpc" "infra" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Public subnets
resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.infra.id
  cidr_block              = cidrsubnet(aws_vpc.infra.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.enable_public_ip

  tags = {
    Name        = "public-subnet-${count.index}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.infra.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route Table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.infra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "public-route-table"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


# # Create a VPC with public subnets and an internet gateway

# provider "aws" {
#   region = var.region 
# }
# data "aws_availability_zones" "available" {}


# # Create a VPC 
# resource "aws_vpc" "infra" {

#  cidr_block = var.vpc_cidr



#  tags = {

#    Name = "main-vpc-eks"

#  }

# }


# # Create public subnets in each availability zone
# resource "aws_subnet" "public_subnet" {

#  count                   = 2

#  vpc_id                  = aws_vpc.infra

#  cidr_block              = cidrsubnet(aws_vpc.infra.cidr_block, 8, count.index)

#  availability_zone       = data.aws_availability_zones.available.names[count.index]

#  map_public_ip_on_launch = true



#  tags = {

#    Name = "public-subnet-${count.index}"

#  }

# }


# # Create an internet gateway and attach it to the VPC
# resource "aws_internet_gateway" "internet_gateway" {

#  vpc_id = aws_vpc.infra.id



#  tags = {

#    Name = "infra-igw"

#  }

# }


# # Create a route table for the public subnets
# resource "aws_route_table" "public_route_table" {

#  vpc_id = aws_vpc.infra.id



#  route {

#    cidr_block = "0.0.0.0/0"

#    gateway_id = aws_internet_gateway.internet_gateway.id

#  }



#  tags = {

#    Name = "infra-route-table"

#  }

# }


# # Associate the public subnets with the route table
# resource "aws_route_table_association" "a" {

#  count          = 2

#  subnet_id      = aws_subnet.public_subnet.*.id[count.index]

#  route_table_id = aws_route_table.public_route_table.id

# }


# create vpc
# resource "aws_vpc" "infra" {
#   cidr_block              = var.vpc_cidr
#   instance_tenancy        = "default"
#   enable_dns_hostnames    = true

#   tags      = {
#     Name    = "${var.project_name}-vpc"
#   }
# }

# # create internet gateway and attach it to vpc
# resource "aws_internet_gateway" "internet_gateway" {
#   vpc_id    = aws_vpc.infra.id

#   tags      = {
#     Name    = "${var.project_name}-igw"
#   }
# }

# # use data source to get all avalablility zones in region
# data "aws_availability_zones" "available_zones" {}

# # create public subnet az1
# resource "aws_subnet" "public_subnet_az1" {
#   vpc_id                  = aws_vpc.infra.id
#   cidr_block              = var.public_subnet_az1_cidr
#   availability_zone       = data.aws_availability_zones.available_zones.names[0]
#   map_public_ip_on_launch = true

#   tags      = {
#     Name    = "public-subnet-${count.index}"
#   }
# }

# # create public subnet az2
# resource "aws_subnet" "public_subnet_az2" {
#   vpc_id                  = aws_vpc.infra.id
#   cidr_block              = var.public_subnet_az2_cidr
#   availability_zone       = data.aws_availability_zones.available_zones.names[1]
#   map_public_ip_on_launch = true

#   tags      = {
#     Name    = "public subnet az2"
#   }
# }

# # create route table and add public route
# resource "aws_route_table" "public_route_table" {
#   vpc_id       = aws_vpc.infra.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.internet_gateway.id
#   }

#   tags       = {
#     Name     = "public route table"
#   }
# }

# # associate public subnet az1 to "public route table"
# resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
#   subnet_id           = aws_subnet.public_subnet_az1.id
#   route_table_id      = aws_route_table.public_route_table.id
# }

# # associate public subnet az2 to "public route table"
# resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
#   subnet_id           = aws_subnet.public_subnet_az2.id
#   route_table_id      = aws_route_table.public_route_table.id
# }


