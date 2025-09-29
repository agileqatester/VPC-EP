# modules/provider_vpc_b/variables.tf

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for first private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for second private subnet"
  type        = string
}

variable "lb_subnet_1_cidr" {
  description = "CIDR block for first load balancer subnet"
  type        = string
}

variable "lb_subnet_2_cidr" {
  description = "CIDR block for second load balancer subnet"
  type        = string
}

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

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

