module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = "oozou-exam-01"
  cidr = "10.35.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.35.1.0/24", "10.35.2.0/24", "10.35.3.0/24"]
  public_subnets  = ["10.35.101.0/24", "10.35.102.0/24", "10.35.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}