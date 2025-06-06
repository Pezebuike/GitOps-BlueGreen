# Input Variables
# AWS Region
region = "eu-west-2"

# AWS VPC ID
vpc_id = "value-of-vpc-id"  

# AWS EC2 Instance Type
instance_type = "t2.micro"


# AWS EC2 Instance Key Pair
# variable = "terraform-key"

# AWS EC2 Instance Security Group
Security_Group = "sg-093c74b1501b45c83"

project_name = "infra"

environment = "dev"

business_division = "DevOps"


common_tags = {
  Name        = local.owners
  Environment = var.environment
  Project     = var.project_name
  Business    = var.business_division
}