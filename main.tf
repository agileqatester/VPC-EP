# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "provider_vpc_b" {
  source = "./modules/provider_vpc_b"
  
  vpc_cidr                 = var.vpc_cidr
  private_subnet_1_cidr    = var.private_subnet_1_cidr
  private_subnet_2_cidr    = var.private_subnet_2_cidr
  lb_subnet_1_cidr         = var.lb_subnet_1_cidr
  lb_subnet_2_cidr         = var.lb_subnet_2_cidr
  project_name             = var.project_name
  environment              = var.environment
  aws_region               = var.aws_region
  availability_zones       = data.aws_availability_zones.available.names
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  project_name    = var.project_name
  environment     = var.environment
  s3_bucket_name  = var.s3_bucket_name
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.provider_vpc_b.vpc_id
  private_subnet_1_id    = module.provider_vpc_b.private_subnet_1_id
  instance_type          = var.instance_type
  root_volume_size       = var.root_volume_size
  root_volume_iops       = var.root_volume_iops
  root_volume_throughput = var.root_volume_throughput
  public_key_path        = var.public_key_path
  s3_bucket_name         = var.s3_bucket_name
  aws_region             = var.aws_region
  ec2_instance_profile   = module.iam.ec2_instance_profile_name
  vpc_endpoints          = module.provider_vpc_b.vpc_endpoints
}

# EIC Module
module "eic" {
  source = "./modules/eic"
  
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.provider_vpc_b.vpc_id
  private_subnet_2_id = module.provider_vpc_b.private_subnet_2_id
  ec2_security_group_id = module.ec2.ec2_security_group_id
}

# Load Balancer Module
module "lb" {
  source = "./modules/lb"
  
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.provider_vpc_b.vpc_id
  lb_subnet_ids    = module.provider_vpc_b.lb_subnet_ids
  ec2_instance_id  = module.ec2.ec2_instance_id
  lb_type          = var.lb_type
  lb_scheme        = var.lb_scheme
  app_port         = var.app_port
}

# DNS Module (optional - for future use)
module "dns" {
  source = "./modules/dns"
  
  project_name     = var.project_name
  environment      = var.environment
  aws_region       = var.aws_region
  vpc_id           = module.provider_vpc_b.vpc_id
  domain_name      = var.domain_name
  lb_dns_name      = module.lb.lb_dns_name
  lb_zone_id       = module.lb.lb_zone_id
  
  count = var.enable_dns ? 1 : 0
}