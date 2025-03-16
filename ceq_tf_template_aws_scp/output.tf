output "scp_policy_ids" {
  description = "The IDs of the created SCP policies"
  value = { for policy in aws_organizations_policy.scp_policies : policy.name => policy.id }
}

output "scp_policy_arns" {
  description = "The ARNs of the created SCP policies"
  value = { for policy in aws_organizations_policy.scp_policies : policy.name => policy.arn }
}





