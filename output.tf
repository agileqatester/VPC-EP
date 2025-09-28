# outputs.tf

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.provider_vpc_b.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.provider_vpc_b.vpc_cidr
}

# Subnet Outputs
output "private_subnet_1_id" {
  description = "ID of the first private subnet (EC2)"
  value       = module.provider_vpc_b.private_subnet_1_id
}

output "private_subnet_2_id" {
  description = "ID of the second private subnet (EIC)"
  value       = module.provider_vpc_b.private_subnet_2_id
}

output "lb_subnet_ids" {
  description = "IDs of the load balancer subnets"
  value       = module.provider_vpc_b.lb_subnet_ids
}

output "lb_subnet_1_id" {
  description = "ID of the first load balancer subnet"
  value       = module.provider_vpc_b.lb_subnet_1_id
}

output "lb_subnet_2_id" {
  description = "ID of the second load balancer subnet"
  value       = module.provider_vpc_b.lb_subnet_2_id
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.ec2_instance_id
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.ec2_instance_private_ip
}

# EIC Outputs
output "eic_endpoint_id" {
  description = "ID of the EIC endpoint"
  value       = module.eic.eic_endpoint_id
}

output "eic_endpoint_dns_name" {
  description = "DNS name of the EIC endpoint"
  value       = module.eic.eic_endpoint_dns_name
}

# Load Balancer Outputs
output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.lb.lb_dns_name
}

output "lb_arn" {
  description = "ARN of the load balancer"
  value       = module.lb.lb_arn
}

# DNS Outputs (only when DNS module is enabled)
output "domain_name" {
  description = "Domain name (if DNS module is enabled)"
  value       = var.enable_dns ? module.dns[0].domain_name : null
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID (if DNS module is enabled)"
  value       = var.enable_dns ? module.dns[0].hosted_zone_id : null
}

# Connection Information
output "connection_info" {
  description = "Information for connecting to the infrastructure"
  value = {
    load_balancer_url = "http://${module.lb.lb_dns_name}"
    eic_connect_command = "aws ec2-instance-connect ssh --instance-id ${module.ec2.ec2_instance_id} --os-user ec2-user --connection-type eice"
    session_manager_command = "aws ssm start-session --target ${module.ec2.ec2_instance_id}"
  }
}