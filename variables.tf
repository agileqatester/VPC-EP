# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "eic-private-ec2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for first private subnet (EC2)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for second private subnet (EIC Endpoint)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "lb_subnet_1_cidr" {
  description = "CIDR block for first load balancer subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "lb_subnet_2_cidr" {
  description = "CIDR block for second load balancer subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 30
}

variable "root_volume_iops" {
  description = "IOPS for GP3 volume (3000-16000)"
  type        = number
  default     = 3000
}

variable "root_volume_throughput" {
  description = "Throughput for GP3 volume in MB/s (125-1000)"
  type        = number
  default     = 125
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing packages and web content"
  type        = string
}

variable "lb_type" {
  description = "Load balancer type (application or network)"
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

variable "enable_dns" {
  description = "Enable DNS module for custom domain"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for the application (required if enable_dns is true)"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port number for the application server"
  type        = number
  default     = 8080
}