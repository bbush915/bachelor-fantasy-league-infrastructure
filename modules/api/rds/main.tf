provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

/* Begin Previously Defined Resources */

data "terraform_remote_state" "bfl_vpc" {
  backend = "s3"

  config = {
    region  = var.aws_region
    profile = var.aws_profile
    bucket  = var.tf-state-bucket
    key     = "api/vpc/terraform.tfstate"
  }
}

/* End Previously Defined Resources */

resource "aws_security_group" "api_db_sg" {
  vpc_id = data.terraform_remote_state.bfl_vpc.outputs.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
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
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_db_subnet_group" "api_db_subnet_group" {
  subnet_ids = data.terraform_remote_state.bfl_vpc.outputs.private_subnet_ids
}

resource "aws_db_instance" "api_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  port                   = 5432
  instance_class         = "db.t2.micro"
  identifier             = "bfl-${var.environment}"
  name                   = var.name
  username               = var.username
  password               = var.password
  vpc_security_group_ids = [aws_security_group.api_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.api_db_subnet_group.name
  apply_immediately      = true

  tags = {
    Application = "Bachelor Fantasy League"
  }
}
