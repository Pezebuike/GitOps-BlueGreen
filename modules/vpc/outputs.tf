output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.infra.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.infra.cidr_block
}

output "public_subnets" {
    # This output will return all public subnets created in the module
  value       = aws_subnet.public_subnet[*].id

}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public_subnet[*].cidr_block
}

output "private_subnets" {
  description = "List of private subnets created in the module"
  value       = aws_subnet.private_subnet[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = aws_subnet.private_subnet[*].cidr_block
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public_route_table.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = [for subnet in aws_subnet.public_subnet : subnet.availability_zone]
}


output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  value       = aws_vpc.infra.enable_dns_hostnames
}