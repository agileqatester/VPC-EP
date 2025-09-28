# modules/eic/outputs.tf

output "eic_endpoint_id" {
  description = "ID of the EIC endpoint"
  value       = aws_ec2_instance_connect_endpoint.main.id
}

output "eic_endpoint_dns_name" {
  description = "DNS name of the EIC endpoint"
  value       = aws_ec2_instance_connect_endpoint.main.dns_name
}

output "eic_security_group_id" {
  description = "Security group ID for EIC endpoint"
  value       = aws_security_group.eic_endpoint.id
}