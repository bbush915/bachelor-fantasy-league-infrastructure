remote_state {
  backend = "s3"

  config = {
    profile = "bfl"
    region  = "us-east-1"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true

    bucket = "bfl-terraform-state-production"
    s3_bucket_tags = {
      Application = "Bachelor Fantasy League"
    }

    dynamodb_table = "bfl-terraform-state-lock-table-production"
    dynamodb_table_tags = {
      Application = "Bachelor Fantasy League"
    }
  }
}

inputs = {
  aws_profile     = "bfl"
  aws_region      = "us-east-1"
  environment     = "production"
  tf-state-bucket = "bfl-terraform-state-production"
}
