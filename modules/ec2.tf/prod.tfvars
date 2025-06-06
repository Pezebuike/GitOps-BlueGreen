# Input Variables
# AWS Region
region = "us-east-1"

# AWS VPC ID
vpc_id = "value-of-vpc-id"  

# AWS EC2 Instance Type
instance_type = "t3.micro"


# AWS EC2 Instance Key Pair
# variable = "terraform-key"

# AWS EC2 Instance Security Group
Security_Group = "sg-0a1b2c3d4e5f6g7h8"

project_name = "infra"

environment = "prod"

business_division = "DevOps"


common_tags = {
  Name        = local.owners
  Environment = var.environment
  Project     = var.project_name
  Business    = var.business_division
}