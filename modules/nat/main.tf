# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet pub-sub-1-a
resource "aws_eip" "eip-nat-a" {
  domain = "vpc"

  tags = {
    Name = "eip-nat-a"
  }
}

# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet pub-sub-2-b
resource "aws_eip" "eip-nat-b" {
  domain = "vpc"

  tags = {
    Name = "eip-nat-b"
  }
}

# create nat gateway in public subnet pub-sub-1a
resource "aws_nat_gateway" "nat-a" {
  allocation_id = aws_eip.eip-nat-a.id
  subnet_id     = var.pub_sub_1a_id

  tags = {
    Name = "nat-a"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  depends_on = [var.igw_id]
}

# create nat gateway in public subnet pub-sub-1-a
resource "aws_nat_gateway" "nat-b" {
  allocation_id = aws_eip.eip-nat-b.id
  subnet_id     = var.pub_sub_2b_id

  tags = {
    Name = "nat-b"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  depends_on = [var.igw_id]
}

# create route table and add public route
resource "aws_route_table" "pub-rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "pub-rt"
  }
}

# associate public subnet pub-sub-1a to public route table
resource "aws_route_table_association" "pub-sub-1a-rt-a" {
  subnet_id      = var.pub_sub_1a_id
  route_table_id = aws_route_table.pub-rt.id
}

# associate public subnet pub-sub-1b to public route table
resource "aws_route_table_association" "pub-sub-2b-rt-a" {
  subnet_id      = var.pub_sub_2b_id
  route_table_id = aws_route_table.pub-rt.id
}

# create private route table pri-rt-a and add route through nat-a
resource "aws_route_table" "pri-rt-a" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-a.id
  }

  tags = {
    Name = "pri-rt-a"
  }
}

# associate private subnet pri-sub-3-a with private route table pri-rt-a
resource "aws_route_table_association" "pri-sub-3a-pri-rt-a" {
  subnet_id      = var.pri_sub_3a_id
  route_table_id = aws_route_table.pri-rt-a.id
}

# associate private subnet pri-sub-5a with private route pri-rt-a
resource "aws_route_table_association" "pri-sub-5a-pri-rt-a" {
  subnet_id      = var.pri_sub_5a_id
  route_table_id = aws_route_table.pri-rt-a.id
}

# create private route table Pri-rt-b and add route through nat-b
resource "aws_route_table" "pri-rt-b" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-b.id
  }

  tags = {
    Name = "pri-rt-b"
  }
}

# associate private subnet pri-sub-4-b with private route table pri-rt-b
resource "aws_route_table_association" "pri-sub-4b-pri-rt-b" {
  subnet_id      = var.pri_sub_4b_id
  route_table_id = aws_route_table.pri-rt-b.id
}

# associate private subnet pri-sub-6b with private route table pri-rt-b
resource "aws_route_table_association" "pri-sub-6b-pri-rt-b" {
  subnet_id      = var.pri_sub_6b_id
  route_table_id = aws_route_table.pri-rt-b.id
}
