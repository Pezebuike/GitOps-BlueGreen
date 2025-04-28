variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
    }

variable "cluster_version" {
    description = "Version of the EKS cluster"
    type        = string
    default     = "1.31"
    validation {
        condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
        error_message = "Cluster version must be in the format X.Y (e.g., 1.31)"
    }
    }

# Node group configuration
# This variable defines the configuration for EKS managed node groups.

variable "eks_managed_node_groups" {
    description = "Configuration for EKS managed node groups"
    type        = map(object({
        instance_types = list(string)
        min_size       = number
        max_size       = number
        desired_size   = number
    }))
    default     = {}
    }   

variable "project_name" {
    description = "Name of the project"
    type        = string
    }

variable "environment" {
    description = "Environment name (e.g., dev, prod)"
    type        = string

    }
variable "tags" {
    description = "Tags to apply to the resources"
    type        = map(string)
    default     = {}
    }
variable "vpc_id" {
    description = "VPC ID where the EKS cluster will be created"
    type        = string
    default     = "vpc-0b9e56fb5f79efb4c"
    }
variable "subnet_ids" {
    description = "List of subnet IDs where the EKS cluster will be created"
    type        = list(string)
    default     = []
    }
variable "region" {
    description = "AWS region where the EKS cluster will be created"
    type        = string
    }
  
