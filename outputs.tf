output "my_organizational_units" {
  description = "List of organizational units from the organizations module"
  value       = module.organizations.organizational_units
}

#-----------SCP OUTPUT--------------------#
output "scp_policy_ids" {
  description = "The IDs of the created SCP policies"
  value = module.scp_policies.scp_policy_ids
}

output "scp_policy_arns" {
  description = "The ARNs of the created SCP policies"
  value = module.scp_policies.scp_policy_arns
}

#---------------SSO PERMISSION SET----------------------#
output "permission_sets" {
  value = module.permission_sets.permission_sets_arn
}



output "cloudtrail_log_group_name" {
    value = module.root-cloudtrail.cloudwatch_logs_group_name
  
}

output "key_id" {
  value = module.kms.key_id
  
}

output "key_arn" {
  value = module.kms.key_arn
  
}

# output "admin_account_id" {
#   value = module.guardduty.admin_account_id
# }

