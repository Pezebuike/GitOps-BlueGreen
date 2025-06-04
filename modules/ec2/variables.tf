# Input Variables
# AWS Region
variable "region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = ""
}

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instnace Type"
  type = string
  default = ""
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key Pair that need to be associated with EC2 Instance"
  type = string
default = ""
}

# AWS EC2 Instance Security Group
# variable "instance_security_group" {
#   description = "AWS EC2 Security Group that need to be associated with EC2 Instance"
#   type = string
#   default = ""
# }

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = ""
  
}
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = ""
}
variable "business_division" {
  description = "Business Division name (e.g., dev, prod)"
  type        = string
  default     = ""
}