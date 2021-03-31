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
