# Input Variables
# AWS Region
region = "eu-north-1"


# AWS EC2 Instance Type
instance_type = "t3.micro"


# AWS EC2 Instance Key Pair
# variable = "terraform-key"

# AWS EC2 Instance Security Group
# Security_Group = "sg-08bf49e60d2c4aab5"

vpc_id = "vpc-05cf292cb56e2c960"

project_name = "infra"

environment = "dev"

business_division = "DevOps"


common_tags = {
  Name        = local.owners
  Environment = var.environment
  Project     = var.project_name
  Business    = var.business_division
}