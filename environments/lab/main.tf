# =============================================================================
# ROOT MODULE — Lab environment
# Wires all modules together
# To destroy expensive resources only: terraform apply -var="enable_nat_gateway=false"
# To destroy everything:               terraform destroy
# =============================================================================

module "networking" {
  source = "../../modules/networking"

  project                  = var.project
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  enable_nat_gateway       = var.enable_nat_gateway
}

module "security_groups" {
  source = "../../modules/security-groups"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  vpc_cidr    = module.networking.vpc_cidr
  my_ip_cidr  = var.my_ip_cidr
}

module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
}

module "bastion" {
  source = "../../modules/bastion"

  project              = var.project
  environment          = var.environment
  ami_id               = var.ami_id
  subnet_id            = module.networking.public_subnet_ids[0]
  sg_id                = module.security_groups.bastion_sg_id
  iam_instance_profile = module.iam.bastion_instance_profile
  key_name             = var.key_name
}

module "ec2" {
  source = "../../modules/ec2"

  project              = var.project
  environment          = var.environment
  ami_id               = var.ami_id
  subnet_id            = module.networking.private_app_subnet_ids[0]
  sg_id                = module.security_groups.web_sg_id
  iam_instance_profile = module.iam.web_ec2_instance_profile
  key_name             = var.key_name
}

module "alb" {
  source = "../../modules/alb"

  project           = var.project
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  web_ec2_id        = module.ec2.instance_id
  certificate_arn   = var.certificate_arn
}

module "waf" {
  source = "../../modules/waf"

  project         = var.project
  environment     = var.environment
  alb_arn         = module.alb.alb_arn
  rate_limit      = var.rate_limit
  blocked_ip_list = var.blocked_ip_list
}

module "rds" {
  source = "../../modules/rds"

  project               = var.project
  environment           = var.environment
  private_db_subnet_ids = module.networking.private_db_subnet_ids
  rds_sg_id             = module.security_groups.rds_sg_id
  db_password           = var.db_password
  multi_az              = var.rds_multi_az
  skip_final_snapshot   = var.skip_final_snapshot
}
