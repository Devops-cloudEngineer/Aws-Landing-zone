output "alarm_name" {
  value       = aws_cloudwatch_metric_alarm.billing_alarm.alarm_name
  description = "Billing Alarm Name"
}

output "metric_name" {
  value       = aws_cloudwatch_metric_alarm.billing_alarm.metric_name
  description = "Metric Name"
}


