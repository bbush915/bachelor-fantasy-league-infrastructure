provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

/* Begin Previously Defined Resources */

data "terraform_remote_state" "web_app_acm" {
  backend = "s3"

  config = {
    region  = var.aws_region
    profile = var.aws_profile
    bucket  = var.tf-state-bucket
    key     = "web-app/acm/terraform.tfstate"
  }
}

data "terraform_remote_state" "web_app_s3" {
  backend = "s3"

  config = {
    region  = var.aws_region
    profile = var.aws_profile
    bucket  = var.tf-state-bucket
    key     = "web-app/s3/terraform.tfstate"
  }
}

/* End Previously Defined Resources */

resource "aws_cloudfront_distribution" "web_app_cdn" {
  origin {
    domain_name = data.terraform_remote_state.web_app_s3.outputs.bucket_regional_domain_name
    origin_id   = "s3-${data.terraform_remote_state.web_app_s3.outputs.bucket_id}"
  }

  default_cache_behavior {
    target_origin_id       = "s3-${data.terraform_remote_state.web_app_s3.outputs.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  price_class = "PriceClass_100"
  aliases     = [var.domain, "www.${var.domain}"]

  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.web_app_acm.outputs.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  default_root_object = "index.html"
  is_ipv6_enabled     = true
  enabled             = true

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 0
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  tags = {
    Application = "Bachelor Fantasy League"
  }
}
