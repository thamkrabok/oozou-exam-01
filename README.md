# oozou-exam-01

**First of all, I have designed infrastructure or architecture of this system.
You can look from this linked "https://drive.google.com/file/d/1FpFVDG-f0JY9zM-ZcTnfNPPKa3A_g2O7/view?usp=sharing"**

**Git structure**

 /$ENV [Contains Backend,Intrastrucures, and Dependencies for each environments]

 /$ENV/Backend [Contains Terraform files for create S3 and Dynamo which using for backend of Infrastructure]

 /$ENV/Dependecies [Contains storageclass.yml, Helm charts of Graphite, and deployment-app-send-metrics.yml]

 /.github/workflows [Contains terraform.yml for triggers to Terraform Cloud]
****

**My journey**

1. I have prepared Terraform Cloud 1 Project and 6 Workspaces below.
    - Projects: belieftfeks
        - Workspaces:
            - oozou-exam-01-DEV-backend
            - oozou-exam-01-DEV-infra
            - oozou-exam-01-UAT-backend
            - oozou-exam-01-UAT-infra            
            - oozou-exam-01-PRD-backend
            - oozou-exam-01-PRD-infra            

    Workspace backend for trigger run plan in /$ENV/Backend

    Workspace infra for trigger run plan in /$ENV/Infrastructure

2. I have prepared Terraform Files in /$ENV/Backend to create S3 bucket and DynamoDB for collect .tfstate.
    - s3.tf contains resources "s3".
    - dynamo.tf contains resources "dynamodb_table".

    
3. I have prepared Terraform Files to create VPC, EKS, EFS and Add-ons (Module EKS Blueprints + Module EFS) in /$ENV/Infrastructure.
    - backend.tf for reference backend of this Terraform.
    ```
    terraform {
        backend "s3" {
            bucket         = "s3-eks-blueprint-01-dev"
            key            = "s3-eks-blueprint-01-dev/terraform.tfstate"
            region         = "ap-southeast-1"
            encrypt        = true
            dynamodb_table = "eks-blueprint-lock"
        }
    }
    ```
    - 0-network.tf contains module "vpc" for create VPC to using in this system.
    ```
    module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> 5.1.2"
    name = "vpc-eks-blueprints-dev"
    cidr = "10.35.0.0/16"
    azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
    private_subnets = ["10.35.1.0/24", "10.35.2.0/24", "10.35.3.0/24"]
    public_subnets  = ["10.35.101.0/24", "10.35.102.0/24", "10.35.103.0/24"]
    enable_nat_gateway     = true
    single_nat_gateway     = true
    one_nat_gateway_per_az = false
    }
    ```
    - 1-eks.tf contains module "eks" for create EKS cluster and node groups for app and metrics-server via labels.

    ```
    module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 19.17"

    cluster_name                   = "eks-blueprints-01"
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
    ```
    - 2-efs.tf contains module "clouddrove/efs/aws"  for create EFS which it will using by Graphite-server.

    ```
    module "efs" {
      source                    = "clouddrove/efs/aws"
      version                   = "1.3.0"
      name                      = "efs-eks-uat"
      region                    = "ap-southeast-1"
      creation_token            = "yay"
      availability_zones        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
      vpc_id                    = module.vpc.vpc_id
      subnets                   = module.vpc.private_subnets
      security_groups           = [module.vpc.default_security_group_id]
      efs_backup_policy_enabled = true
    }
    ```


