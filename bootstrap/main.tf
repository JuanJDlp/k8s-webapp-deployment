provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.s3_name
  tags   = var.tags
force_destroy = true
}

resource "aws_dynamodb_table" "tfstate_table" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}
