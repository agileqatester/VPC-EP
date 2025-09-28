# modules/provider_vpc_b/main.tf

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway (needed for NAT Gateway and external LB)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Private Subnet 1 (for EC2 instance)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zones[0]
  
  tags = {
    Name        = "${var.project_name}-private-subnet-1"
    Environment = var.environment
    Purpose     = "EC2"
  }
}

# Private Subnet 2 (for EIC Endpoint)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zones[1]
  
  tags = {
    Name        = "${var.project_name}-private-subnet-2"
    Environment = var.environment
    Purpose     = "EIC"
  }
}

# Load Balancer Subnet 1 (can be private or public based on scheme)
resource "aws_subnet" "lb_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.lb_subnet_1_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false  # Will be modified if internet-facing LB is used
  
  tags = {
    Name        = "${var.project_name}-lb-subnet-1"
    Environment = var.environment
    Purpose     = "LoadBalancer"
  }
}

# Load Balancer Subnet 2 (second AZ for ALB requirement)
resource "aws_subnet" "lb_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.lb_subnet_2_cidr
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false
  
  tags = {
    Name        = "${var.project_name}-lb-subnet-2"
    Environment = var.environment
    Purpose     = "LoadBalancer"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# Route Table for Load Balancer Subnet
resource "aws_route_table" "lb" {
  vpc_id = aws_vpc.main.id
  
  # Add route to internet gateway if external load balancer is needed
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name        = "${var.project_name}-lb-rt"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "lb_1" {
  subnet_id      = aws_subnet.lb_1.id
  route_table_id = aws_route_table.lb.id
}

resource "aws_route_table_association" "lb_2" {
  subnet_id      = aws_subnet.lb_2.id
  route_table_id = aws_route_table.lb.id
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for VPC endpoints"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC"
  }
  
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }
  
  tags = {
    Name        = "${var.project_name}-vpc-endpoints-sg"
    Environment = var.environment
  }
}

# VPC Endpoints for Session Manager
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = {
    Name        = "${var.project_name}-ssm-endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = {
    Name        = "${var.project_name}-ssmmessages-endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  
  tags = {
    Name        = "${var.project_name}-ec2messages-endpoint"
    Environment = var.environment
  }
}

# S3 VPC Endpoint (Gateway type)
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]
  
  tags = {
    Name        = "${var.project_name}-s3-endpoint"
    Environment = var.environment
  }
}