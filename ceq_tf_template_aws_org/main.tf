### Existing Organization
data "aws_organizations_organization" "existing" {}

# Enable Trusted Access for Services
resource "null_resource" "enable_trusted_access" {
  for_each = var.aws_service_access_principals

  provisioner "local-exec" {
    command = "aws organizations enable-aws-service-access --service-principal ${each.value}"

    environment = {
      AWS_REGION = var.aws_region
    }
  }
}

# Fetch all existing OUs to reference parents
data "aws_organizations_organizational_units" "all" {
  parent_id = data.aws_organizations_organization.existing.roots[0].id
}

### Create Parent OUs First
resource "aws_organizations_organizational_unit" "Parent" {
  for_each = {
    for ou_name, ou in var.organizational_units : ou_name => ou if ou.parent_name == ""
  }

  name      = each.key
  parent_id = data.aws_organizations_organization.existing.roots[0].id
  tags      = var.tags
}

### Create Child OUs After Parents
resource "aws_organizations_organizational_unit" "children" {
  for_each = {
    for ou_name, ou in var.organizational_units : ou_name => ou if ou.parent_name != ""
  }

  name      = each.key
  parent_id = lookup(
    aws_organizations_organizational_unit.Parent,
    each.value.parent_name,
    null
  ) != null ? aws_organizations_organizational_unit.Parent[each.value.parent_name].id : data.aws_organizations_organization.existing.roots[0].id
  tags      = var.tags

  depends_on = [aws_organizations_organizational_unit.Parent]
}

resource "aws_organizations_delegated_administrator" "example" {
  count    = var.delegated_config ? 1 : 0
  account_id        = var.delegated_config_account #"881490103380"
  service_principal = var.service_principal_config  #"config.amazonaws.com"
}


