provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Application = "Bachelor Fantasy League"
    Name        = "bfl_vpc_${var.environment}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  tags = {
    Application = "Bachelor Fantasy League"
    Name        = "bfl_default_sg_${var.environment}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Application = "Bachelor Fantasy League"
    Name        = "bfl_ig_${var.environment}"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "public_1" {
  availability_zone       = "${var.aws_region}a"
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Application = "Bachelor Fantasy League"
    Name        = "bfl_public_subnet_${var.environment}"
    Public      = "true"
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_vpc.default.main_route_table_id
}

resource "aws_subnet" "private_1" {
  availability_zone       = "${var.aws_region}b"
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Application = "Bachelor Fantasy League"
    Name        = "bfl_private_subnet_1_${var.environment}"
  }
}

resource "aws_subnet" "private_2" {
  availability_zone       = "${var.aws_region}c"
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    Application = "Bachelor Fantasy League"
    Name        = "bfl_private_subnet_2_${var.environment}"
  }
}
