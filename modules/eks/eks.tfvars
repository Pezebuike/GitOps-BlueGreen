project_name = "k8s-infra"
business_division = "DevOps"
environment = "dev"
vpc_id = "vpc-0482c76de4aee215f"
region = "eu-west-2"
subnet_ids = ["subnet-0f7dea9373052c6b9","subnet-0d1e129e00a2953cd" ]
cluster_name = "k8s-eks-cluster" 
cluster_version = "1.31"    
eks_managed_node_groups = {
  primary = {
    instance_types = ["t3.medium"]
    min_size       = 1
    max_size       = 1
    desired_size   = 1
  }
}

