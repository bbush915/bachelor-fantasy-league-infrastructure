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

resource "aws_security_group" "default" {
  vpc_id = data.terraform_remote_state.bfl_vpc.outputs.vpc_id

  ingress {
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
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_instance" "default" {
  ami                    = "ami-0742b4e673072066f"
  instance_type          = "t2.micro"
  key_name               = var.ssh_key
  subnet_id              = data.terraform_remote_state.bfl_vpc.outputs.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.default.id]

  tags = {
    Application = "Bachelor Fantasy League"
  }
}
