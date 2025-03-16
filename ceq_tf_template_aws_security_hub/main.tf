
# Enable AWS Security Hub in the management account 
resource "aws_securityhub_account" "main" {
  enable_default_standards  = var.enable_default_standards
  #control_finding_generator = var.control_finding_generator
  auto_enable_controls      = var.auto_enable_controls
  provider                  = aws
}


# Designate a member account as the Security Hub admin
resource "aws_securityhub_organization_admin_account" "admin" {
  admin_account_id = var.delegated_admin_id  # Use the variable for the delegated admin account ID
  depends_on      = [aws_securityhub_account.main] 
}

# Automatically enable Security Hub for new member accounts
resource "aws_securityhub_organization_configuration" "auto_enable_new_accounts" {
  provider = aws.delegated_admin  # Use the provider configured for the delegated admin account
  auto_enable = var.auto_enable_security_hub  # Enable automatic setup for new accounts
  depends_on  = [aws_securityhub_organization_admin_account.admin]  # Ensure the admin account is designated first
}

# Loop through each member account and create a Security Hub member
#resource "aws_securityhub_member" "members" {
  #for_each = { for account in var.member_accounts : account.id => account }

  #provider   = aws.delegated_admin # Use the provider configured for the delegated admin account
  #account_id = each.value.id         # Use the current account ID in the loop
  #email      = each.value.email      # Use the current account email in the loop
  #invite      = false
  #depends_on = [aws_securityhub_organization_admin_account.admin]
#}

resource "aws_securityhub_member" "members" {
  for_each = toset(var.member_account_ids)
  provider   = aws.delegated_admin 
  account_id = each.value
  #master_id   = var.delegated_admin_id
  depends_on = [aws_securityhub_organization_admin_account.admin]
  lifecycle {
    ignore_changes = [invite]  # Ignore changes to the invite attribute
  }

}
