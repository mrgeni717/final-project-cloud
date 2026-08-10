output "state_bucket_name" {
  description = "S3 bucket name to use in every other module's backend block"
  value       = aws_s3_bucket.tf_state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name to use in every other module's backend block"
  value       = aws_dynamodb_table.tf_locks.name
}
