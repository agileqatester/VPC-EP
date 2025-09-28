
output "vpc_id" { value = aws_vpc.this.id }
output "consumer_instance_id" { value = aws_instance.consumer.id }
output "vpc_endpoint_dns_entries" { value = aws_vpc_endpoint.consumer_vpce.dns_entry }
