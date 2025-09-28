# modules/eic/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_2_id" {
  description = "ID of the private subnet for EIC endpoint"
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security group ID of the EC2 instance"
  type        = string
}