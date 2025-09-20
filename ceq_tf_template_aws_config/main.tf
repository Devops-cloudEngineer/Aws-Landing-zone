#-----------------------------------------------------------------------------------------------------------------------
# LOCALS AND DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------
data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
data "aws_partition" "current" {}

locals {
  is_central_account                      = var.central_resource_collector_account == data.aws_caller_identity.this.account_id
  is_global_recorder_region               = var.global_resource_collector_region == data.aws_region.this.id
  child_resource_collector_accounts       = var.child_resource_collector_accounts != null ? var.child_resource_collector_accounts : []
  create_organization_aggregator_iam_role = var.create_organization_aggregator_iam_role
  partition                               = data.aws_partition.current.partition
}

resource "aws_config_configuration_recorder" "recorder" {
  count    = var.is_aws_config_configuration_recorder_create ? 1 : 0
  name     = "config-recorder"
  role_arn = var.create_iam_role ? aws_iam_role.config-recorder-role.arn : var.iam_role_arn
  dynamic "recording_group" {
    for_each = var.recording_group != null ? [1] : []
    content {
      all_supported                 = var.recording_group.all_supported
      include_global_resource_types = var.recording_group.include_global_resource_types
      dynamic "exclusion_by_resource_types" {
        for_each = var.recording_group.all_supported == true ? [] : [1]
        content {
          resource_types = var.recording_group.exclusion_by_resource_types.excluded_resource_type
        }
      }
      dynamic "recording_strategy" {
        for_each = var.recording_group.all_supported == true ? [] : [1]
        content {
          use_only = var.recording_group.recording_strategy.use_only
        }
      }
      resource_types = var.recording_group.all_supported == true ? [] : var.recording_group.resource_types

    }
  }

  dynamic "recording_mode" {
    for_each = var.recording_mode != null ? [1] : []
    content {
      recording_frequency = var.recording_mode.recording_frequency
      dynamic "recording_mode_override" {
        for_each = var.recording_mode.recording_mode_override != null ? [1] : []
        content {
          description         = var.recording_mode.recording_mode_override.description
          recording_frequency = var.recording_mode.recording_mode_override.recording_frequency
          resource_types      = var.recording_mode.recording_mode_override.resource_types
        }
      }
    }
  }
}

resource "aws_config_delivery_channel" "channel" {

  count          = var.create_delivery_channel ? 1 : 0
  name           = var.name
  s3_bucket_name = var.delivery_bucket_name
  s3_kms_key_arn = var.s3_kms_key_arn
  s3_key_prefix  = var.s3_key_prefix
  sns_topic_arn  = var.sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  count      = var.create_recorder_status ? 1 : 0
  name       = aws_config_configuration_recorder.recorder[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

resource "aws_config_config_rule" "rules" {
  for_each   = var.create_config_rule ? var.managed_rules : {}
  depends_on = [aws_config_configuration_recorder_status.recorder_status, aws_lambda_permission.example]

  name                        = each.key
  description                 = each.value.description
  maximum_execution_frequency = each.value.maximum_execution_frequency
  dynamic "scope" {
    for_each = each.value.scope != null && each.value.scope != {} ? [each.value.scope] : []

    content {
      compliance_resource_id    = scope.value.compliance_resource_id
      compliance_resource_types = scope.value.compliance_resource_types
      tag_key                   = scope.value.tag_key
      tag_value                 = scope.value.tag_value
    }
  }

  dynamic "source" {
    for_each = each.value.source
    content {
      owner             = each.value.owner
      source_identifier = each.value.owner == "CUSTOM_LAMBDA" ? var.lambda_arn : each.value.source_identifier
      dynamic "source_detail" {
        for_each = each.value.source_detail
        content {
          event_source                = each.value.event_source
          maximum_execution_frequency = each.value.maximum_execution_frequency
          message_type                = each.value.message_type
        }
      }
      dynamic "custom_policy_details" {
        for_each = each.value.custom_policy_details
        content {
          enable_debug_log_delivery = each.value.enable_debug_log_delivery
          policy_runtime            = each.value.policy_runtime
          policy_text               = each.value.policy_text
        }

      }
    }
  }

  input_parameters = length(each.value.input_parameters) > 0 ? jsonencode(each.value.input_parameters) : null
  tags             = each.value.tags


}


resource "aws_lambda_permission" "example" {
  for_each = {
    for key, rule in var.managed_rules : key => rule if rule.source.owner == "CUSTOM_LAMBDA"
  }
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "config.amazonaws.com"
  statement_id  = "AllowExecutionFromConfig"
}

resource "aws_config_configuration_aggregator" "this" {
  # Create the aggregator in the global recorder region of the central AWS Config account. This is usually the
  # "security" account
  count    = var.is_aggregator ? 1 : 0

  name = var.name
  # Create normal account aggregation source
  dynamic "account_aggregation_source" {
    for_each = var.is_organization_aggregator ? [] : [1]
    content {
      account_ids = local.child_resource_collector_accounts
      regions     = var.account_aggregation_source.regions
    }
  }

  # Create organization aggregation source
  dynamic "organization_aggregation_source" {
    for_each = var.is_organization_aggregator ? [1] : []
    content {
      all_regions = var.organization_aggregation_source.all_regions
      role_arn    = local.create_organization_aggregator_iam_role ? aws_iam_role.iam_role_organization_aggregator[0].arn : var.iam_role_organization_aggregator_arn
      # regions     = var.organization_aggregation_source.regions
    }
  }

}

resource "aws_config_aggregate_authorization" "central" {
  count    = var.central_resource_collector_account != null && var.is_organization_aggregator_child == true ? 1 : 0
  account_id = data.aws_caller_identity.this.account_id
  region     = var.global_resource_collector_region
  tags = var.tags
}

resource "aws_config_aggregate_authorization" "child" {

  count = var.central_resource_collector_account != null && var.is_organization_aggregator_child == true ? 1 : 0

  account_id = var.central_resource_collector_account
  region     = var.global_resource_collector_region

  tags = var.tags
}

resource "aws_config_retention_configuration" "example" {
  retention_period_in_days = var.retention_period
}




#IAM

resource "aws_iam_role" "config-recorder-role" {
  name               = "config-recorder-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}
resource "aws_iam_role" "iam_role_organization_aggregator" {
  count              = var.is_organization_aggregator ? 1 : 0
  name               = "iam_role_organization_aggregator"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "config-recorder-policy" {
  name     = "config-recorder-policy"
  role     = aws_iam_role.config-recorder-role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:*"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.delivery_bucket_name}",
          "arn:aws:s3:::${var.delivery_bucket_name}/*"
        ],
        "Condition" : {
          "StringLike" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        "Sid" : "AWSConfigKMSPolicy",
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*"
        ],
        "Resource" : var.s3_kms_key_arn
      }
    ]
  })
}

data "aws_iam_policy" "aws_config_built_in_role" {
  arn      = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}
data "aws_iam_policy" "aws_config_organization_role" {
  arn      = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config-recorder-role.name
  policy_arn = data.aws_iam_policy.aws_config_built_in_role.arn
}

resource "aws_iam_role_policy_attachment" "organization_config_policy_attachment" {
  count    = var.create_iam_role && var.is_organization_aggregator ? 1 : 0

  role = aws_iam_role.iam_role_organization_aggregator[0].name

  policy_arn = data.aws_iam_policy.aws_config_organization_role.arn
}
