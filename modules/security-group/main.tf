# InternetFacing-alb-sg
resource "aws_security_group" "internet_facing_alb_sg" {
  name        = "internet-facing-alb-sg"
  description = "Internet facing load balancer security group: enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "internet-facing-alb-sg"
  }
}

# WebTier-sg
resource "aws_security_group" "web_tier_sg" {
  name        = "WebTier-sg"
  description = "Security group for the web tier: enable http/https access on port 80"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internet_facing_alb_sg.id]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebTier-sg"
  }
}

# Internal-alb-sg
resource "aws_security_group" "internal_alb_sg" {
  name        = "Internal-alb-sg"
  description = "Internal load balancer security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Internal-alb-sg"
  }
}

# AppTier-sg
resource "aws_security_group" "app_tier_sg" {
  name        = "AppTier-sg"
  description = "AppTier instance security group: enable tcp access on port 4000"
  vpc_id      = var.vpc_id

  ingress {
    description     = "tcp access"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb_sg.id]
  }

  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AppTier-sg"
  }
}

# create security group for the Database
resource "aws_security_group" "db_tier_sg" {
  name        = "DBTier-sg"
  description = "DBTier security group for MySQL/Aurora: enable tcp access on port 3306"
  vpc_id      = var.vpc_id

  ingress {
    description     = "mysql access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier_sg.id]
  }

  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier_sg.id, aws_security_group.app_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DBTier-sg"
  }
}
