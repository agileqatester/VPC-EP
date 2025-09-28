
variable "region"        { type = string }
variable "project_name"  { type = string }
variable "vpc_cidr"      { type = string }
variable "instance_type" { type = string, default = "t3.micro" }
variable "provider_service_name" { type = string }

# Key management
variable "use_existing_key_pair"  { type = bool,   default = true }
variable "existing_key_pair_name" { type = string, default = "" }
