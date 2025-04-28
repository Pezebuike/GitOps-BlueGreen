project_name = "infra"
environment = "dev"
vpc_id = "vpc-0014f5e3762f3dc42"
region = "eu-west-2"
subnet_ids = [ "subnet-066eb2e1a46637d93","subnet-0b83fe74bb02a0acb" ]
cluster_name = "k8s-eks-cluster" 
cluster_version = "1.31"    
eks_managed_node_groups = {
  primary = {
    instance_types = ["t3.medium"]
    min_size       = 1
    max_size       = 3
    desired_size   = 2
  }
}

