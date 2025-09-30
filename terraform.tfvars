# terraform.tfvars.example

# Basic Configuration
aws_region   = "us-east-1"
project_name = "eic-private-ec2"
environment  = "dev"

# VPC Configuration
vpc_cidr               = "10.0.0.0/16"
private_subnet_1_cidr  = "10.0.1.0/24"  # EC2 subnet
private_subnet_2_cidr  = "10.0.2.0/24"  # EIC endpoint subnet
lb_subnet_1_cidr       = "10.0.3.0/24"  # Load balancer subnet 1 (AZ-a)
lb_subnet_2_cidr       = "10.0.4.0/24"  # Load balancer subnet 2 (AZ-b)

# EC2 Configuration (environment-driven)
public_key_path        = "~/.ssh/id_rsa.pub"

# S3 Configuration
s3_bucket_name = "my-private-ec2-packages-20250921204451"

# Load Balancer Configuration
lb_type   = "network"  # Required for VPC Endpoint Service
lb_scheme = "internal"  # Internal for PrivateLink
# Web App port
app_port = 8080

# Consumer VPC Configuration
consumer_vpc_cidr = "10.1.0.0/16"

# DNS Configuration
enable_dns  = false                    # Public DNS for provider VPC (optional)
domain_name = "example.local"          # Public domain (only if enable_dns = true)
private_dns_zone   = "provider.local"  # Private DNS zone in consumer VPC
private_dns_record = "api"             # Service name: api.provider.local