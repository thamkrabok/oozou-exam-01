module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"
  name = "vpc-eks-blueprints-prd"
  cidr = "10.55.0.0/16"
  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.55.1.0/24", "10.55.2.0/24", "10.55.3.0/24"]
  public_subnets  = ["10.55.101.0/24", "10.55.102.0/24", "10.55.103.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}
