# modules/ec2/main.tf

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}



# Security Group for EC2 Instance
resource "aws_security_group" "ec2" {
  name_prefix = "${var.project_name}-ec2-"
  vpc_id      = var.vpc_id
  description = "Security group for EC2 instance"
  
  # SSH access (CRITICAL: This was missing!)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Allow SSH from VPC
    description = "SSH access"
  }
  
  # HTTP access for Python server on port var.app_port = 8080
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTP for Python server"
  }
  
  # HTTP port 80 for Load Balancer target
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTP for Load Balancer"
  }
  
  # HTTPS access (future use)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTPS access"
  }
  
  # Outbound HTTPS for S3 and VPC endpoints
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to S3 and VPC endpoints"
  }
  
  # DNS resolution
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DNS resolution (UDP)"
  }
  
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DNS resolution (TCP)"
  }
  
  # HTTP for package repositories
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for package repositories"
  }
  
  # Outbound for app port (VPC Endpoint)
  egress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTP to VPC Endpoint"
  }
  
  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-keypair"
  public_key = file(var.public_key_path)
  
  tags = {
    Name        = "${var.project_name}-keypair"
    Environment = var.environment
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                     = data.aws_ami.amazon_linux.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.main.key_name
  vpc_security_group_ids  = [aws_security_group.ec2.id]
  subnet_id               = var.private_subnet_1_id
  iam_instance_profile    = var.ec2_instance_profile
  
  # Force recreation when user_data changes
  lifecycle {
    create_before_destroy = true
  }
  
  # Explicit dependencies on VPC endpoints
  depends_on = [var.vpc_endpoints]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    s3_bucket_name = var.s3_bucket_name
    hostname       = "${var.project_name}-server"
    aws_region     = var.aws_region
    app_port       = var.app_port 
  }))
  
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
  }
}

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.project_name}"
  retention_in_days = 14
  
  tags = {
    Name        = "${var.project_name}-log-group"
    Environment = var.environment
  }
}