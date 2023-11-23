module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.17"

  cluster_name                   = "oozou-exam-eks"
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }

    dev-app = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "dev"
        app  = "yes"
      }      
    }    

    dev-metric = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "dev"
        graphite  = "yes"
      }      
    }        

  }    
  

  manage_aws_auth_configmap = true
  aws_auth_roles            = []
  aws_auth_users            = []
}