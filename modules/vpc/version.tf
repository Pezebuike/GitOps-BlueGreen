# Terraform Block
terraform {
  required_version = ">= 1.4" 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}

# Provider Block
provider "aws" {
  region  = var.region
}

