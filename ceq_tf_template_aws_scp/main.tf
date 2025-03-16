
# Create multiple SCP Policies
resource "aws_organizations_policy" "scp_policies" {
  for_each    = { for policy in var.scp_policies : policy.name => policy }

  content     = each.value.content
  name        = each.value.name
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"

  tags = var.tags
}

# Attach each SCP Policy to the specified Organizational Units or Accounts
resource "aws_organizations_policy_attachment" "scp_attachments" {
  for_each =  { for policy in var.scp_policies : policy.name => policy }

  policy_id = aws_organizations_policy.scp_policies[each.value.name].id
  target_id = each.value.target_ids
}
