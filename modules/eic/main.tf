# modules/eic/main.tf

# Security Group for EIC Endpoint
resource "aws_security_group" "eic_endpoint" {
  name_prefix = "${var.project_name}-eic-endpoint-"
  vpc_id      = var.vpc_id
  description = "Security group for EIC Endpoint"
  
  # HTTPS for EIC service
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for EIC service"
  }
  
  # Egress for HTTPS (needed for EIC service communication)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for EIC service communication"
  }
  
  tags = {
    Name        = "${var.project_name}-eic-endpoint-sg"
    Environment = var.environment
  }
}

# Security Group Rules for SSH communication between EIC and EC2
resource "aws_security_group_rule" "ec2_ssh_from_eic" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eic_endpoint.id
  security_group_id        = var.ec2_security_group_id
  description              = "SSH from EIC Endpoint"
}

resource "aws_security_group_rule" "eic_ssh_to_ec2" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.ec2_security_group_id
  security_group_id        = aws_security_group.eic_endpoint.id
  description              = "SSH to EC2 instances"
}

# EIC Endpoint
resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = var.private_subnet_2_id
  security_group_ids = [aws_security_group.eic_endpoint.id]
  
  tags = {
    Name        = "${var.project_name}-eic-endpoint"
    Environment = var.environment
  }
}