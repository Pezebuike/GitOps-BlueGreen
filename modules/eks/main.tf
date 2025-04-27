provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name != null ? var.cluster_name : "${var.project_name}-${var.environment}-eks-cluster"
  cluster_version = var.cluster_version
  
  # Optional
  cluster_endpoint_public_access = true
  
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
  
  eks_managed_node_groups = var.eks_managed_node_groups
  
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  tags = merge({
    Name        = "${var.project_name}-${var.environment}-eks-cluster"
    Environment = var.environment
    Terraform   = "true"
  }, var.tags)
}