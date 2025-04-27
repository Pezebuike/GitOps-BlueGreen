project_name = "infra" # Replace with your project name
environment = "dev" # Replace with your environment name (e.g., dev, prod)
vpc_id = "vpc-0b9e56fb5f79efb4c" # Replace with your VPC ID
region = "eu-west-2" # Replace with your desired AWS region
subnet_ids = [ "subnet-054725bc8e7493015","subnet-036be5e11dfdfb73e" ]
cluster_name = "k8s-eks-cluster" # Replace with your desired cluster name
cluster_version = "1.31"    
eks_managed_node_groups = {
  primary = {
    instance_types = ["t3.medium"]
    min_size       = 1
    max_size       = 3
    desired_size   = 2
  }
}

