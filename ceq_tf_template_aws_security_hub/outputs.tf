output "admin_account_id" {
  value = aws_securityhub_organization_admin_account.admin.admin_account_id
}

output "member_account_ids" {
  value = [for member in aws_securityhub_member.members : member.account_id]
}
