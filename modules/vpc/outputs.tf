output "region" {
  value = var.region
}

output "project_name" {
  value = var.project_name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.infra.id
}

output "public_subnets" {
    # This output will return all public subnets created in the module
  value       = aws_subnet.public_subnet[*].id

}



output "internet_gateway" {
  value = aws_internet_gateway.internet_gateway
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public_subnet[*].cidr_block
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