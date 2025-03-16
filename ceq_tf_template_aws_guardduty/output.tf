output "detector_id" {
  value = aws_guardduty_detector.MyDetector.id
}

output "detector_arn" {
  value = aws_guardduty_detector.MyDetector.arn
}


output "admin_account_id" {
  value = aws_guardduty_organization_admin_account.MyGDOrgDelegatedAdmin.id
}


output "aws_guardduty_publishing_destination" {
  value = aws_guardduty_publishing_destination.pub_dest.id
}

