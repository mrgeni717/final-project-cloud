resource "aws_sns_topic" "db_alerts" {
  name = "${var.project_slug}-db-alerts"
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_slug}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization above 80% for 10 minutes"
  alarm_actions       = [aws_sns_topic.db_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.project_slug}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods   = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2000000000 # 2 GB, in bytes
  alarm_description   = "RDS free storage below 2 GB"
  alarm_actions       = [aws_sns_topic.db_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}
