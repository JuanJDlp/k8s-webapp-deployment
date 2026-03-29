output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.tfstate_bucket.id
}

output "dynamodb_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.tfstate_table.name
}
