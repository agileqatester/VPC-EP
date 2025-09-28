# modules/lb/main.tf

# Security Group for Load Balancer
resource "aws_security_group" "lb" {
  name_prefix = "${var.project_name}-lb-"
  vpc_id      = var.vpc_id
  description = "Security group for Load Balancer"
  
  # HTTP ingress
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.lb_scheme == "internet-facing" ? ["0.0.0.0/0"] : ["10.0.0.0/8"]
    description = "HTTP access"
  }
  
  # HTTPS ingress
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.lb_scheme == "internet-facing" ? ["0.0.0.0/0"] : ["10.0.0.0/8"]
    description = "HTTPS access"
  }
  
  # All outbound traffic to targets
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "All traffic to targets"
  }
  
  tags = {
    Name        = "${var.project_name}-lb-sg"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  count = var.lb_type == "application" ? 1 : 0
  
  name               = "${var.project_name}-alb"
  internal           = var.lb_scheme == "internal"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.lb_subnet_ids
  
  enable_deletion_protection = false
  
  # Access logs can be enabled later
  # access_logs {
  #   bucket  = var.s3_bucket_name
  #   prefix  = "lb-logs"
  #   enabled = true
  # }
  
  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
  }
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  count = var.lb_type == "network" ? 1 : 0
  
  name               = "${var.project_name}-nlb"
  internal           = var.lb_scheme == "internal"
  load_balancer_type = "network"
  subnets            = var.lb_subnet_ids
  
  enable_deletion_protection = false
  
  tags = {
    Name        = "${var.project_name}-nlb"
    Environment = var.environment
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "alb" {
  count = var.lb_type == "application" ? 1 : 0
  
  name     = "${var.project_name}-alb-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  tags = {
    Name        = "${var.project_name}-alb-tg"
    Environment = var.environment
  }
}

# Target Group for NLB
resource "aws_lb_target_group" "nlb" {
  count = var.lb_type == "network" ? 1 : 0
  
  name     = "${var.project_name}-nlb-tg"
  port     = var.app_port
  protocol = "TCP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 6
    unhealthy_threshold = 2
  }
  
  tags = {
    Name        = "${var.project_name}-nlb-tg"
    Environment = var.environment
  }
}

# Target Group Attachment for ALB
resource "aws_lb_target_group_attachment" "alb" {
  count = var.lb_type == "application" ? 1 : 0
  
  target_group_arn = aws_lb_target_group.alb[0].arn
  target_id        = var.ec2_instance_id
  port             = var.app_port
}

# Target Group Attachment for NLB
resource "aws_lb_target_group_attachment" "nlb" {
  count = var.lb_type == "network" ? 1 : 0
  
  target_group_arn = aws_lb_target_group.nlb[0].arn
  target_id        = var.ec2_instance_id
  port             = var.app_port
}

# ALB Listener (HTTP)
resource "aws_lb_listener" "alb_http" {
  count = var.lb_type == "application" ? 1 : 0
  
  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb[0].arn
  }
}

# NLB Listener (TCP)
resource "aws_lb_listener" "nlb_tcp" {
  count = var.lb_type == "network" ? 1 : 0
  
  load_balancer_arn = aws_lb.nlb[0].arn
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb[0].arn
  }
}