resource "aws_eip" "nat" {
  tags = {
    Name        = "nat-${var.env}"
    Environment = var.env
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = tolist(data.aws_subnets.public.ids)[0]

  tags = {
    Name        = "nat-${var.env}"
    Environment = var.env
  }

  depends_on = [aws_eip.nat]
}

resource "aws_route" "private_nat" {
  route_table_id         = data.aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  depends_on = [aws_nat_gateway.this]
}
