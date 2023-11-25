module "efs" {
      source                    = "clouddrove/efs/aws"
      version                   = "1.3.0"
      name                      = "efs-eks-prd"
      region                    = "ap-southeast-1"
      creation_token            = "yay"
      availability_zones        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
      vpc_id                    = module.vpc.vpc_id
      subnets                   = module.vpc.private_subnets
      security_groups           = [module.vpc.default_security_group_id]
      efs_backup_policy_enabled = true
}
