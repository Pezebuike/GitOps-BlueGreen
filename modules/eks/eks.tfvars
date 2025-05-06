project_name = "k8s-infra"
business_division = "DevOps"
environment = "dev"
vpc_id = "vpc-08d9aa11bafb4b3d0"
region = "eu-west-2"
subnet_ids = ["subnet-0e29cb660f2ad3d90","subnet-0f1e09c7b5f23d650" ]
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

