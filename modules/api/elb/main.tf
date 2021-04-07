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

data "terraform_remote_state" "bfl_acm" {
  backend = "s3"

  config = {
    region  = var.aws_region
    profile = var.aws_profile
    bucket  = var.tf-state-bucket
    key     = "web-app/acm/terraform.tfstate"
  }
}

/* End Previously Defined Resources */

resource "aws_security_group" "api_lb_sg" {
  vpc_id = data.terraform_remote_state.bfl_vpc.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_lb" "api_lb_target" {
  subnets         = data.terraform_remote_state.bfl_vpc.outputs.public_subnet_ids
  security_groups = [aws_security_group.api_lb_sg.id]

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_alb_target_group" "api_lb_target" {
  vpc_id = data.terraform_remote_state.bfl_vpc.outputs.vpc_id

  protocol    = "HTTP"
  port        = 4000
  target_type = "ip"

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_alb_listener" "api_lb_listener" {
  load_balancer_arn = aws_lb.api_lb_target.arn

  protocol        = "HTTPS"
  port            = 443
  certificate_arn = data.terraform_remote_state.bfl_acm.outputs.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.api_lb_target.arn
    type             = "forward"
  }
}


