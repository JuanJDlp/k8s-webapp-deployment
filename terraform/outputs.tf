output "s3_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = aws_s3_bucket.tfstate_bucket.id
}

output "dynamodb_name" {
  description = "Name of the Terraform lock DynamoDB table"
  value       = aws_dynamodb_table.tfstate_table.name
}
