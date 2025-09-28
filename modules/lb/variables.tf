# modules/lb/variables.tf

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

variable "lb_subnet_ids" {
  description = "IDs of the load balancer subnets"
  type        = list(string)
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance to target"
  type        = string
}

variable "lb_type" {
  description = "Type of load balancer (application or network)"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network"], var.lb_type)
    error_message = "Load balancer type must be either 'application' or 'network'."
  }
}

variable "lb_scheme" {
  description = "Load balancer scheme (internet-facing or internal)"
  type        = string
  default     = "internet-facing"
  validation {
    condition     = contains(["internet-facing", "internal"], var.lb_scheme)
    error_message = "Load balancer scheme must be either 'internet-facing' or 'internal'."
  }
}

variable "app_port" {
  description = "Port number for the application server"
  type        = number
  default     = 8080
}