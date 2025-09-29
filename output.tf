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

# Consumer VPC Outputs
output "consumer_vpc_id" {
  description = "ID of the Consumer VPC"
  value       = module.consumer_vpc_a.vpc_id
}

output "consumer_instance_id" {
  description = "ID of the Consumer EC2 instance"
  value       = module.consumer_ec2.ec2_instance_id
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries for the VPC Endpoint"
  value       = aws_vpc_endpoint.consumer_to_provider.dns_entry
}

output "provider_service_name" {
  description = "VPC Endpoint Service name for PrivateLink"
  value       = aws_vpc_endpoint_service.provider_service.service_name
}

# Environment Configuration Reminder
output "IMPORTANT_var_file_reminder" {
  description = "Reminder to use environment-specific var files"
  value = "\n\n🚨 For proper environment configuration, use:\n\n  Dev:  terraform apply -var-file=environments/dev.tfvars -var-file=terraform.tfvars\n  Prod: terraform apply -var-file=environments/prod.tfvars -var-file=terraform.tfvars\n\n  Same for destroy operations.\n"
}

# Connection Information
output "connection_info" {
  description = "Information for connecting to the infrastructure"
  value = {
    provider_load_balancer_url = "http://${module.lb.lb_dns_name}"
    provider_eic_connect_command = "aws ec2-instance-connect ssh --instance-id ${module.ec2.ec2_instance_id} --os-user ec2-user --connection-type eice"
    provider_session_manager_command = "aws ssm start-session --target ${module.ec2.ec2_instance_id}"
    consumer_eic_connect_command = "aws ec2-instance-connect ssh --instance-id ${module.consumer_ec2.ec2_instance_id} --os-user ec2-user --connection-type eice"
    consumer_session_manager_command = "aws ssm start-session --target ${module.consumer_ec2.ec2_instance_id}"
    vpc_endpoint_test_url = "http://${aws_vpc_endpoint.consumer_to_provider.dns_entry[0].dns_name}"
    privatelink_test_reminder = "From consumer EC2, test PrivateLink: curl http://${var.private_dns_record}.${var.private_dns_zone}:${var.app_port}"
  }
}