# modules/lb/outputs.tf

locals {
  lb_arn      = var.lb_type == "application" ? (length(aws_lb.main) > 0 ? aws_lb.main[0].arn : "") : (length(aws_lb.nlb) > 0 ? aws_lb.nlb[0].arn : "")
  lb_dns_name = var.lb_type == "application" ? (length(aws_lb.main) > 0 ? aws_lb.main[0].dns_name : "") : (length(aws_lb.nlb) > 0 ? aws_lb.nlb[0].dns_name : "")
  lb_zone_id  = var.lb_type == "application" ? (length(aws_lb.main) > 0 ? aws_lb.main[0].zone_id : "") : (length(aws_lb.nlb) > 0 ? aws_lb.nlb[0].zone_id : "")
}

output "lb_arn" {
  description = "ARN of the load balancer"
  value       = local.lb_arn
}

output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = local.lb_dns_name
}

output "lb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = local.lb_zone_id
}

output "lb_security_group_id" {
  description = "Security group ID of the load balancer"
  value       = aws_security_group.lb.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value = var.lb_type == "application" ? (
    length(aws_lb_target_group.alb) > 0 ? aws_lb_target_group.alb[0].arn : ""
  ) : (
    length(aws_lb_target_group.nlb) > 0 ? aws_lb_target_group.nlb[0].arn : ""
  )
}