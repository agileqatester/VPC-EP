# Prod Environment Configuration
environment = "prod"
confirm_var_files = true

# EC2 Configuration
instance_type          = "t3.2xlarge"
root_volume_size       = 100
root_volume_iops       = 10000
root_volume_throughput = 500

# Production HA Configuration
enable_asg             = true
asg_min_size           = 2
asg_max_size           = 4
asg_desired_capacity   = 2