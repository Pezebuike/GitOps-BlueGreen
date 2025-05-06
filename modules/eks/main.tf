module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
 
  cluster_name    = var.cluster_name != null ? var.cluster_name : "${local.name}-eks-cluster"
  cluster_version = var.cluster_version
 
  # Optional
  cluster_endpoint_public_access = true
 
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
 
  eks_managed_node_groups = var.eks_managed_node_groups
 
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
 
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-eks-cluster"
    }
  )
}

# Local-exec provisioner to output EKS cluster details to a file
resource "null_resource" "eks_output_to_file" {
  # Ensure this runs after the EKS cluster is created
  depends_on = [
    module.eks
  ]
  # This will run the command locally after the EKS cluster is created
  provisioner "local-exec" {
    command = <<-EOT
      cat > eks_info.txt << EOF
EKS Cluster Information:
------------------------
Cluster Name: ${module.eks.cluster_name}
Cluster ARN: ${module.eks.cluster_arn}
Cluster Endpoint: ${module.eks.cluster_endpoint}
Cluster Version: ${module.eks.cluster_version}
Cluster Security Group ID: ${module.eks.cluster_security_group_id}
EKS Managed Node Groups:
-----------------------
${join("\n", [for name, ng in module.eks.eks_managed_node_groups : "Node Group: ${name}"])}
Cluster IAM Role ARN: ${module.eks.cluster_iam_role_arn}
OIDC Provider ARN: ${module.eks.oidc_provider_arn}
Cluster Addons:
--------------
${module.eks.cluster_addons != null ? join("\n", [for name, addon in module.eks.cluster_addons : "Addon: ${name}, Version: ${addon.addon_version}"]) : "No addons configured"}
VPC Configuration:
-----------------
VPC ID: ${var.vpc_id}
Subnet IDs: ${join(", ", var.subnet_ids)}
Created by Terraform on: $(date)
EOF
    EOT
  }
  # This will run when terraform destroy is executed
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'EKS Cluster destroyed on: $(date)' > eks_destruction_log.txt"
  }
}