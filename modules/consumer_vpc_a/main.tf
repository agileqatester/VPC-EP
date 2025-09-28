
data "aws_availability_zones" "available" {
  state = "available"
}

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

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  vpc_a_priv_t1 = [ cidrsubnet(var.vpc_cidr, 4, 0), cidrsubnet(var.vpc_cidr, 4, 1) ]
  vpc_a_priv_t2 = [ cidrsubnet(var.vpc_cidr, 4, 2), cidrsubnet(var.vpc_cidr, 4, 3) ]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc-a" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-a-private-rt" }
}

resource "aws_subnet" "priv_t1" {
  for_each = { for idx, az in local.azs : az => { cidr = local.vpc_a_priv_t1[idx], az = az } }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = { Name = "${var.project_name}-a-priv-t1-${each.value.az}", Tier = "private-1" }
}

resource "aws_subnet" "priv_t2" {
  for_each = { for idx, az in local.azs : az => { cidr = local.vpc_a_priv_t2[idx], az = az } }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = { Name = "${var.project_name}-a-priv-t2-${each.value.az}", Tier = "private-2" }
}

resource "aws_route_table_association" "t1_assoc" {
  for_each       = aws_subnet.priv_t1
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "t2_assoc" {
  for_each       = aws_subnet.priv_t2
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# EIC endpoint in first private subnet
resource "aws_security_group" "eic_sg" {
  name   = "${var.project_name}-a-eic-sg"
  vpc_id = aws_vpc.this.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  tags = { Name = "${var.project_name}-a-eic-sg" }
}

resource "aws_ec2_instance_connect_endpoint" "eic" {
  subnet_id          = values(aws_subnet.priv_t1)[0].id
  security_group_ids = [aws_security_group.eic_sg.id]
  tags               = { Name = "${var.project_name}-a-eic" }
}

# Consumer instance
resource "aws_security_group" "consumer_sg" {
  name   = "${var.project_name}-a-consumer-sg"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eic_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-a-consumer-sg" }
}

resource "aws_instance" "consumer" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type
  subnet_id                   = values(aws_subnet.priv_t1)[0].id
  vpc_security_group_ids      = [aws_security_group.consumer_sg.id]
  associate_public_ip_address = false
  key_name                    = var.existing_key_pair_name
  tags = { Name = "${var.project_name}-a-consumer" }
}

# Interface VPC Endpoint to Provider service
resource "aws_security_group" "vpce_sg" {
  name   = "${var.project_name}-a-vpce-sg"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.consumer_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-a-vpce-sg" }
}

resource "aws_vpc_endpoint" "consumer_vpce" {
  vpc_id              = aws_vpc.this.id
  service_name        = var.provider_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [values(aws_subnet.priv_t2)[0].id, values(aws_subnet.priv_t2)[1].id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = false
  tags = { Name = "${var.project_name}-a-to-b-vpce" }
}
