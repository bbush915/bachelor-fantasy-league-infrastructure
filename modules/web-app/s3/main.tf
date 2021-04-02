provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_s3_bucket" "web_app_bucket" {
  bucket = var.bucket
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Application = "Bachelor Fantasy League"
  }
}

resource "aws_s3_bucket_policy" "web_app_bucket_policy" {
  bucket = aws_s3_bucket.web_app_bucket.id

  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Id": "S3StaticWebsitePublicAccessPolicy",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "${aws_s3_bucket.web_app_bucket.arn}/*",
          "${aws_s3_bucket.web_app_bucket.arn}"
        ]
      }
    ]
  }
  POLICY
}
