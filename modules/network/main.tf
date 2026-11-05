
############################################
# VPC
############################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "khyati-terraform-vpc"
    Environment = "Dev"
    Project     = "AWS-DevOps"
  }
}

############################################
# PUBLIC SUBNET 1
############################################

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = "khyati-public-subnet-1"
    Tier = "Public"
  }
}

############################################
# PUBLIC SUBNET 2
############################################

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "khyati-public-subnet-2"
    Tier = "Public"
  }
}

############################################
# PRIVATE SUBNET 1
############################################

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.az_1

  tags = {
    Name = "khyati-private-subnet-1"
    Tier = "Private"
  }
}

############################################
# PRIVATE SUBNET 2
############################################

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.az_2

  tags = {
    Name = "khyati-private-subnet-2"
    Tier = "Private"
  }
}

############################################
# INTERNET GATEWAY
############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "khyati-internet-gateway"
  }
}

############################################
# PUBLIC ROUTE TABLE
############################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "khyati-public-route-table"
  }
}

############################################
# PUBLIC ROUTE TABLE ASSOCIATIONS
############################################

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

############################################
# PRIVATE ROUTE TABLE
############################################

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "khyati-private-route-table"
  }
}

############################################
# PRIVATE ROUTE TABLE ASSOCIATIONS
############################################

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}
