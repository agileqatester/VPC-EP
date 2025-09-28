# modules/dns/main.tf

# Route53 Private Hosted Zone
resource "aws_route53_zone" "private" {
  name = var.domain_name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name        = "${var.project_name}-private-zone"
    Environment = var.environment
  }
}

# Route53 Record pointing to Load Balancer
resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

# Route53 Record for www subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

# Route53 Health Check for the load balancer (optional)
resource "aws_route53_health_check" "main" {
  count = var.enable_health_check ? 1 : 0
  
  fqdn                            = var.lb_dns_name
  port                            = 80
  type                            = "HTTP"
  resource_path                   = "/health"
  failure_threshold               = "3"
  request_interval                = "30"
  cloudwatch_alarm_region         = var.aws_region
  cloudwatch_alarm_name           = "${var.project_name}-health-check-alarm"
  insufficient_data_health_status = "Unhealthy"

  tags = {
    Name        = "${var.project_name}-health-check"
    Environment = var.environment
  }
}