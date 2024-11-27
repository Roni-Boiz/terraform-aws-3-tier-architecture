module "vpc" {
  source          = "./modules/vpc"
  region          = var.region
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  pub_sub_1a_cidr = var.pub_sub_1a_cidr
  pub_sub_2b_cidr = var.pub_sub_2b_cidr
  pri_sub_3a_cidr = var.pri_sub_3a_cidr
  pri_sub_4b_cidr = var.pri_sub_4b_cidr
  pri_sub_5a_cidr = var.pri_sub_5a_cidr
  pri_sub_6b_cidr = var.pri_sub_6b_cidr
}

module "nat" {
  source        = "./modules/nat"
  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  igw_id        = module.vpc.igw_id
  pub_sub_2b_id = module.vpc.pub_sub_2b_id
  vpc_id        = module.vpc.vpc_id
  pri_sub_3a_id = module.vpc.pri_sub_3a_id
  pri_sub_4b_id = module.vpc.pri_sub_4b_id
  pri_sub_5a_id = module.vpc.pri_sub_5a_id
  pri_sub_6b_id = module.vpc.pri_sub_6b_id
}

module "security-group" {
  source = "./modules/security-group"
  vpc_id = module.vpc.vpc_id
}

module "key" {
  source = "./modules/key"
}

# module "ec2" {
#   source        = "./modules/ec2"
#   pub_sub_1a_id = module.vpc.pub_sub_1a_id
#   pub_sub_2b_id = module.vpc.pub_sub_2b_id
#   pri_sub_3a_id = module.vpc.pri_sub_3a_id
#   pri_sub_4b_id = module.vpc.pri_sub_4b_id
#   pri_sub_5a_id = module.vpc.pri_sub_5a_id
#   pri_sub_6b_id = module.vpc.pri_sub_6b_id
#   web_security_group_id = module.security-group.web_security_group_id
#   app_security_group_id = module.security-group.app_tier_sg_id
#   db_security_group_id = module.security-group.db_security_group_id
#   key_name = module.key.key_name
# }

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  region      = var.region
  environment = "dev"
}

module "alb" {
  source                    = "./modules/alb"
  project_name              = module.vpc.project_name
  internal_alb_sg_id        = module.security-group.internal_alb_sg_id
  internet_facing_alb_sg_id = module.security-group.internet_facing_alb_sg_id
  pub_sub_1a_id             = module.vpc.pub_sub_1a_id
  pub_sub_2b_id             = module.vpc.pub_sub_2b_id
  pri_sub_3a_id             = module.vpc.pri_sub_3a_id
  pri_sub_4b_id             = module.vpc.pri_sub_4b_id
  vpc_id                    = module.vpc.vpc_id
}

module "asg" {
  source       = "./modules/asg"
  project_name = module.vpc.project_name
  key_name     = module.key.key_name

  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  pub_sub_2b_id = module.vpc.pub_sub_2b_id
  pri_sub_3a_id = module.vpc.pri_sub_3a_id
  pri_sub_4b_id = module.vpc.pri_sub_4b_id

  web_tier_sg_id  = module.security-group.web_tier_sg_id
  app_tier_sg_id  = module.security-group.app_tier_sg_id
  web_tier_tg_arn = module.alb.web_tier_alb_tg_arn
  app_tier_tg_arn = module.alb.app_tier_alb_tg_arn

  db_host                     = module.rds.db_host
  db_port                     = module.rds.db_port
  db_user                     = module.rds.db_username
  db_password                 = module.rds.db_password
  db_name                     = module.rds.db_name
  domain                      = module.cloudfront.cloudfront_domain_name
  rds_aurora_cluster_instance = module.rds.rds_aurora_cluster_primary_instance

  bucket_name      = var.bucket_name
  internal_alb_dns = module.alb.internal_alb_dns_name
}

module "rds" {
  source        = "./modules/rds"
  db_sg_id      = module.security-group.db_tier_sg_id
  pri_sub_5a_id = module.vpc.pri_sub_5a_id
  pri_sub_6b_id = module.vpc.pri_sub_6b_id
  db_username   = var.db_username
  db_password   = var.db_password
}

module "cloudfront" {
  source                          = "./modules/cloudfront"
  certificate_domain_name         = var.certificate_domain_name
  internet_facing_alb_domain_name = module.alb.internet_facing_alb_dns_name
  additional_domain_name          = var.additional_domain_name
  project_name                    = module.vpc.project_name
}

module "route53" {
  source                    = "./modules/route53"
  cloudfront_domain_name    = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
}
