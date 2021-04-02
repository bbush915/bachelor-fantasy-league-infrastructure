provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_ecr_repository" "default" {
  name = "bfl_api_repository_${var.environment}"

  tags = {
    Application = "Bachelor Fantasy League"
    Name        = "bfl_api_repository_${var.environment}"
  }
}

resource "aws_iam_role" "ecr_admin_role" {
  name = "bbfl_ecr_admin_role_${var.environment}"

  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ecs-tasks.amazonaws.com",
            "ecs.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy" "ecr_admin_role_policy" {
  role = aws_iam_role.ecr_admin_role.id

  name = "bhp_ecr_admin_role_policy_${var.environment}"

  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "ecr:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "logs:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "ssm:*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}
