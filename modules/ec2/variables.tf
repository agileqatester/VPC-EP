# modules/ec2/variables.tf

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

variable "private_subnet_1_id" {
  description = "ID of the private subnet for EC2"
  type        = string
}



variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ec2_instance_profile" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "vpc_endpoints" {
  description = "VPC endpoints information"
  type = object({
    ssm         = string
    ssmmessages = string
    ec2messages = string
    s3          = string
  })
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
}

variable "root_volume_iops" {
  description = "IOPS for GP3 volume"
  type        = number
}

variable "root_volume_throughput" {
  description = "Throughput for GP3 volume in MB/s"
  type        = number
}

variable "app_port" {
  description = "Port number for the application server"
  type        = number
  default     = 8080
}