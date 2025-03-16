output "aws_config_configuration_recorder_id" {
  value       = join("", aws_config_configuration_recorder.recorder[*].id)
  description = "The ID of the AWS Config Recorder"
}

output "config_recorder_role" {
  description = <<-DOC
  IAM Role used to make read or write requests to the delivery channel and to describe the AWS resources associated with 
  the account.
  DOC
  value       = var.create_iam_role ? aws_iam_role.config-recorder-role.arn : var.iam_role_arn
}

output "iam_role_organization_aggregator" {
  description = <<-DOC
  IAM Role used to make read or write requests to the delivery channel and to describe the AWS resources associated with 
  the account.
  DOC
  value       = local.create_organization_aggregator_iam_role ? aws_iam_role.iam_role_organization_aggregator[0].arn : var.iam_role_organization_aggregator_arn
}

# output "sns_topic" {
#   description = "SNS topic"
#   value       = var.create_sns_topic ? module.sns_topic[0].sns_topic : null
# }
