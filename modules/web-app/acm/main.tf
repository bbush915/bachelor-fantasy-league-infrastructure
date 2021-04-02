provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_acm_certificate" "web_app_certificate" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]

  validation_method = "EMAIL"

  tags = {
    Application = "Bachelor Fantasy League"
  }
}
