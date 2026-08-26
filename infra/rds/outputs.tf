output "db_endpoint" {
  description = "Host:port to connect to (no credentials embedded)"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "master_user_secret_arn" {
  description = "AWS Secrets Manager ARN holding the auto-generated username/password JSON"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "sns_topic_arn" {
  description = "Subscribe an email here (optional) via the AWS Console to get alarm notifications"
  value       = aws_sns_topic.db_alerts.arn
}
