# modules/provider_vpc_b/outputs.tf

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_1_id" {
  description = "ID of the first private subnet"
  value       = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  description = "ID of the second private subnet"
  value       = aws_subnet.private_2.id
}

output "lb_subnet_ids" {
  description = "IDs of the load balancer subnets"
  value       = [aws_subnet.lb_1.id, aws_subnet.lb_2.id]
}

output "lb_subnet_1_id" {
  description = "ID of the first load balancer subnet"
  value       = aws_subnet.lb_1.id
}

output "lb_subnet_2_id" {
  description = "ID of the second load balancer subnet"
  value       = aws_subnet.lb_2.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "lb_route_table_id" {
  description = "ID of the load balancer route table"
  value       = aws_route_table.lb.id
}

output "vpc_endpoints" {
  description = "VPC endpoints information"
  value = {
    ssm         = aws_vpc_endpoint.ssm.id
    ssmmessages = aws_vpc_endpoint.ssmmessages.id
    ec2messages = aws_vpc_endpoint.ec2messages.id
    s3          = aws_vpc_endpoint.s3.id
  }
}

output "vpc_endpoints_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

