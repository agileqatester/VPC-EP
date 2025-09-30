
variable "provider_azs" {
  type        = list(string)
  description = "List of Availability Zones to use (must match provider VPC AZs)"
}

variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}
