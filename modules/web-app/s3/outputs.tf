output "bucket_id" {
  value = aws_s3_bucket.web_app_bucket.id
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.web_app_bucket.bucket_regional_domain_name
}
