# modules/dns/outputs.tf

output "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = aws_route53_zone.private.zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers of the hosted zone"
  value       = aws_route53_zone.private.name_servers
}

output "domain_name" {
  description = "Domain name"
  value       = var.domain_name
}

output "health_check_id" {
  description = "ID of the Route53 health check"
  value       = var.enable_health_check ? aws_route53_health_check.main[0].id : null
}