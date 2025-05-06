variable "region" {
    description = "AWS region to deploy the VPC"
    type        = string
}
variable "project_name" {
    description = "Name of the project"
    type        = string
}

variable "business_division" {
    description = "Business division name"
    type        = string
}

variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
}
variable "public_subnet_count" {
    description = "Number of public subnets to create"
    type        = number
    default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}
variable "enable_public_ip" {
  description = "Enable auto-assign public IP on subnet instances"
  type        = bool
}

variable "environment" {
    description = "Environment name (e.g., dev, prod)"
    type        = string
}
# variable "availability_zones" {
#     description = "List of availability zones to use for the subnets"
#     type        = list(string)
#     default     = []
# }