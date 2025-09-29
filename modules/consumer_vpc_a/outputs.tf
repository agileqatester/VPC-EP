
output "vpc_id" { value = aws_vpc.this.id }
output "eic_subnet_ids" { value = [for subnet in aws_subnet.eic : subnet.id] }
output "ec2_subnet_ids" { value = [for subnet in aws_subnet.ec2 : subnet.id] }
output "vpc_endpoints" {
  value = {
    ssm         = aws_vpc_endpoint.ssm.id
    ssmmessages = aws_vpc_endpoint.ssmmessages.id
    ec2messages = aws_vpc_endpoint.ec2messages.id
    s3          = aws_vpc_endpoint.s3.id
  }
}
