provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_vpc" "bfl_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_default_security_group" "bfl_vpc_default_sg" {
  vpc_id = aws_vpc.bfl_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_internet_gateway" "bfl_ig" {
  vpc_id = aws_vpc.bfl_vpc.id

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.bfl_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bfl_ig.id
}

resource "aws_subnet" "bfl_public_subnet_1" {
  availability_zone       = "${var.aws_region}a"
  vpc_id                  = aws_vpc.bfl_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_subnet" "bfl_public_subnet_2" {
  availability_zone       = "${var.aws_region}d"
  vpc_id                  = aws_vpc.bfl_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_route_table_association" "bfl_rta_public_1" {
  subnet_id      = aws_subnet.bfl_public_subnet_1.id
  route_table_id = aws_vpc.bfl_vpc.main_route_table_id
}

resource "aws_route_table_association" "bfl_rta_public_2" {
  subnet_id      = aws_subnet.bfl_public_subnet_2.id
  route_table_id = aws_vpc.bfl_vpc.main_route_table_id
}

resource "aws_subnet" "bfl_private_subnet_1" {
  availability_zone       = "${var.aws_region}b"
  vpc_id                  = aws_vpc.bfl_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_subnet" "bfl_private_subnet_2" {
  availability_zone       = "${var.aws_region}c"
  vpc_id                  = aws_vpc.bfl_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    Application = "Bachelor Fantasy League"
  }
}
