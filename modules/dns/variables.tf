# modules/dns/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "lb_dns_name" {
  description = "DNS name of the load balancer"
  type        = string
}

variable "lb_zone_id" {
  description = "Zone ID of the load balancer"
  type        = string
}

variable "enable_health_check" {
  description = "Enable Route53 health check"
  type        = bool
  default     = false
}