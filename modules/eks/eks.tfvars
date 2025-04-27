project_name = "infra" # Replace with your project name
environment = "dev" # Replace with your environment name (e.g., dev, prod)
vpc_id = "vpc-12345678" # Replace with your VPC ID
region = "us-west-2" # Replace with your desired AWS region
subnet_ids = [ "value" ]
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
vpc_id = "vpc-12345678" # Replace with your VPC ID