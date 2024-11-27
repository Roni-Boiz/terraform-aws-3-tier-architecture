# create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# create public subnet pub_sub_1a
resource "aws_subnet" "pub_sub_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_1a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-1a"
  }
}

# create public subnet pub_sub_2b
resource "aws_subnet" "pub_sub_2b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_2b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-2b"
  }
}

# create private app subnet pri-sub-3a
resource "aws_subnet" "pri_sub_3a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_3a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-3a"
  }
}

# create private app pri-sub-4b
resource "aws_subnet" "pri_sub_4b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_4b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-4b"
  }
}

# create private data subnet pri-sub-5a
resource "aws_subnet" "pri_sub_5a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_5a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-5a"
  }
}

# create private data subnet pri-sub-6-b
resource "aws_subnet" "pri_sub_6b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_6b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-6b"
  }
}
