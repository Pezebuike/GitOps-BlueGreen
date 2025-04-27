provider "aws" {
  region = var.region
}

module "eks" {
   # Using GitHub source with specific commit hash for security and version control
  # This ensures that the module is always pulled from a specific commit, providing stability and predictability.
  source = "github.com/terraform-aws-modules/terraform-aws-eks?ref=3a8a5cb675b07aea68321a06b1c261d4128ed270"
  version = "~> 20.31"

  cluster_name    = "${var.project_name}-${var.environment}-eks-cluster"
  cluster_version = "1.31"
  
  # Optional
  cluster_endpoint_public_access = true
  
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
  
  eks_managed_node_groups = var.eks_managed_node_groups
  
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster"
    Environment = var.environment
    Terraform   = "true"
  }
}