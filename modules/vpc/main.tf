# Fetch available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC resource
resource "aws_vpc" "infra" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc"
    }
  )
}

# Public subnets
resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.infra.id
  cidr_block              = cidrsubnet(aws_vpc.infra.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.enable_public_ip
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-public-subnet-${count.index}"
    }
  )
}

# Private subnets
resource "aws_subnet" "private_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.infra.id
  cidr_block        = cidrsubnet(aws_vpc.infra.cidr_block, 8, count.index + var.public_subnet_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-private-subnet-${count.index}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.infra.id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-igw"
    }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-nat-eip"
    }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-nat-gateway"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC
  depends_on = [aws_internet_gateway.igw]
}

# Route Table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.infra.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-public-route-table"
    }
  )
}

# Route Table for private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.infra.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-private-route-table"
    }
  )
}

# Route table association with public subnets
resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Route table association with private subnets
resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Local-exec provisioner to output infrastructure details to a file
resource "null_resource" "output_to_file" {
  # Ensure this runs after the VPC and subnets are created
  depends_on = [
    aws_vpc.infra,
    aws_subnet.public_subnet,
    aws_subnet.private_subnet,
    aws_nat_gateway.nat_gateway,
    aws_internet_gateway.igw
  ]

  # Execute command locally after the infrastructure is created
  provisioner "local-exec" {
    command = <<-EOT
      cat > vpc_info.txt << EOF
VPC Information:
----------------
VPC ID: ${aws_vpc.infra.id}
VPC CIDR: ${aws_vpc.infra.cidr_block}

Public Subnets:
--------------
${join("\n", [for i, subnet in aws_subnet.public_subnet : "Subnet ${i}: ID=${subnet.id}, CIDR=${subnet.cidr_block}, AZ=${subnet.availability_zone}"])}

Private Subnets:
---------------
${join("\n", [for i, subnet in aws_subnet.private_subnet : "Subnet ${i}: ID=${subnet.id}, CIDR=${subnet.cidr_block}, AZ=${subnet.availability_zone}"])}

Internet Gateway ID: ${aws_internet_gateway.igw.id}
NAT Gateway ID: ${aws_nat_gateway.nat_gateway.id}
NAT Gateway EIP: ${aws_eip.nat_eip.public_ip}

Created by Terraform on: $(date)
EOF
    EOT
  }

  # This will only run when terraform destroy is executed
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Infrastructure destroyed on: $(date)' > vpc_destruction_log.txt"
  }
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


