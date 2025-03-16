# Create a CloudWatch metric alarm
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  # provider            = aws.destination
  alarm_name                            = var.alarm_name
  comparison_operator                   = var.comparison_operator
  evaluation_periods                    = var.evaluation_periods
  metric_name                           = var.metric_name
  namespace                             = var.namespace
  period                                = var.period
  statistic                             = var.statistic
  threshold                             = var.monthly_billing_threshold
  threshold_metric_id                   = var.threshold_metric_id
  actions_enabled                       = var.actions_enabled
  datapoints_to_alarm                   = var.datapoints_to_alarm
  insufficient_data_actions             = var.insufficient_data_actions
  ok_actions                            = var.ok_actions
  unit                                  = var.unit
  extended_statistic                    = var.extended_statistic
  treat_missing_data                    = var.treat_missing_data
  evaluate_low_sample_count_percentiles = var.evaluate_low_sample_count_percentiles
  alarm_description                     = var.alarm_description

  dimensions = {
    Currency = var.currency
  }

  alarm_actions = var.alarm_actions

  tags = var.tags
}
