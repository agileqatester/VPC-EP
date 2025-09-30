# Dev Environment Configuration
environment = "dev"
confirm_var_files = true

# EC2 Configuration
instance_type          = "t3.micro"
root_volume_size       = 30
root_volume_iops       = 3000
root_volume_throughput = 125

# Development Configuration
enable_asg             = false
asg_min_size           = 1
asg_max_size           = 1
asg_desired_capacity   = 1