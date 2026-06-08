data "aws_region" "current" {}

locals {
  interface_endpoints = toset([
    "ecr.api",
    "ecr.dkr",
    "sts",
    "logs",
    "ec2",
    "ssm",
    "ssmmessages",
    "ec2messages",
  ])
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpce-sg-${var.env}"
  description = "Allow HTTPS from within VPC to interface endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = {
    Name        = "vpce-sg-${var.env}"
    Environment = var.env
  }
}

# free — no hourly charge, adds route to private route table
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name        = "vpce-s3-${var.env}"
    Environment = var.env
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "vpce-${each.key}-${var.env}"
    Environment = var.env
  }
}
