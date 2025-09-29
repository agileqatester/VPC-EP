# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Provider VPC Module
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

# Consumer VPC Module (networking only)
module "consumer_vpc_a" {
  source = "./modules/consumer_vpc_a"
  
  region       = var.aws_region
  project_name = var.project_name
  vpc_cidr     = var.consumer_vpc_cidr
}

# VPC Endpoint Service for PrivateLink
resource "aws_vpc_endpoint_service" "provider_service" {
  acceptance_required        = false
  network_load_balancer_arns = [module.lb.lb_arn]
  allowed_principals         = ["*"]
  
  tags = {
    Name        = "${var.project_name}-endpoint-service"
    Environment = var.environment
  }
}

# Consumer EC2 Module
module "consumer_ec2" {
  source = "./modules/ec2"
  
  project_name           = "${var.project_name}-consumer"
  environment            = var.environment
  vpc_id                 = module.consumer_vpc_a.vpc_id
  private_subnet_1_id    = module.consumer_vpc_a.ec2_subnet_ids[0]
  instance_type          = var.instance_type
  root_volume_size       = var.root_volume_size
  root_volume_iops       = var.root_volume_iops
  root_volume_throughput = var.root_volume_throughput
  public_key_path        = var.public_key_path
  s3_bucket_name         = var.s3_bucket_name
  aws_region             = var.aws_region
  ec2_instance_profile   = module.iam.ec2_instance_profile_name
  vpc_endpoints          = module.consumer_vpc_a.vpc_endpoints
}

# Consumer EIC Module
module "consumer_eic" {
  source = "./modules/eic"
  
  project_name          = "${var.project_name}-consumer"
  environment           = var.environment
  vpc_id                = module.consumer_vpc_a.vpc_id
  private_subnet_2_id   = module.consumer_vpc_a.eic_subnet_ids[0]
  ec2_security_group_id = module.consumer_ec2.ec2_security_group_id
}

# VPC Endpoint for Consumer to Provider connectivity
resource "aws_security_group" "consumer_vpce_sg" {
  name   = "${var.project_name}-consumer-vpce-sg"
  vpc_id = module.consumer_vpc_a.vpc_id
  
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.consumer_vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = { Name = "${var.project_name}-consumer-vpce-sg" }
}

resource "aws_vpc_endpoint" "consumer_to_provider" {
  vpc_id              = module.consumer_vpc_a.vpc_id
  service_name        = aws_vpc_endpoint_service.provider_service.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.consumer_vpc_a.eic_subnet_ids
  security_group_ids  = [aws_security_group.consumer_vpce_sg.id]
  private_dns_enabled = false
  
  tags = { Name = "${var.project_name}-consumer-to-provider-vpce" }
}

# Route53 Private Hosted Zone for friendly DNS
resource "aws_route53_zone" "consumer_private" {
  name = var.private_dns_zone
  
  vpc {
    vpc_id = module.consumer_vpc_a.vpc_id
  }
  
  tags = { Name = "${var.project_name}-consumer-private-zone" }
}

resource "aws_route53_record" "provider_service" {
  zone_id = aws_route53_zone.consumer_private.zone_id
  name    = "${var.private_dns_record}.${var.private_dns_zone}"
  type    = "A"
  
  alias {
    name                   = aws_vpc_endpoint.consumer_to_provider.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.consumer_to_provider.dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
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