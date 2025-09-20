#---------------AWS ORGANIZATON Module ----------------------#
module "organizations" {
  source               = "./ceq_tf_template_aws_org"
  aws_service_access_principals = var.aws_service_access_principals
  organizational_units = var.organizational_units
  delegated_config  = var.delegated_config
  delegated_config_account        = var.delegated_config_account 
  service_principal_config = var.service_principal_config  
  aws_region           = var.region 
  tags                = var.tags
}

#----------------SCP MODULE----------------------------------#
module "scp_policies" {
  source   = "./ceq_tf_template_aws_scp" 
  scp_policies = [
    for policy in var.scp_policies : {
      name        = policy.name
      description = policy.description
      content     = jsonencode(policy.content)
      target_ids = policy.target_ids
    }
  ]
  tags = var.tags
  
}

#--------------------SSO_PERMISSION_SET MODULE-----------------------#
module "permission_sets" {
  source = "./ceq_tf_template_aws_sso_permission_sets"
  permission_sets = var.permission_sets
  tags = var.tags 
    
}


#--------------------CloudTrail-----------------------------#
module "root-cloudtrail" {
  source                            = "./ceq_tf_template_root_account_cloudtrail"
  depends_on = [module.s3]
  enable_cloudwatch_logs            = var.enable_cloudwatch_logs
  name                              = var.name
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  create_kms_key                    = module.kms.key_arn
  #enable_sns_notifications          = module.sns["cloudtrail"].topic_name
  s3_bucket_name                    = module.s3["cloudtrail"].s3_bucket_id
  s3_key_prefix                     = var.s3_key_prefix
  enable_log_file_validation        = var.enable_log_file_validation
  enable_logging                    = var.enable_logging
  include_global_service_events     = var.include_global_service_events
  is_multi_region_trail             = var.is_multi_region_trail
  is_organization_trail             = var.is_organization_trail
  event_selectors                   = var.event_selectors
  insight_selectors                 = var.insight_selectors
  tags                              = var.tags
}

#-------------------------Alerts on Cloudtrail Events-------------------------#

module "alerts" {
  source                    = "./ceq_tf_template_root_account_alert_cloudtrail"
  root_usage                = var.root_usage
  pattern                   = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  comparison_operator       = var.comparison_operator
  cloudtrail_log_group_name = module.root-cloudtrail.cloudwatch_logs_group_name
  metric_name               = var.metric_name
  evaluation_periods        = var.evaluation_periods
  alarm_namespace           = var.alarm_namespace
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  alarm_description         = var.alarm_description
  alarm_sns_topic_arn       = module.sns["cloudtrail"].topic_arn
  tags                      = var.tags

}

#---------------------------- KMS-----------------------------#
module "kms" {
  source                  = "./ceq_tf_template_aws_kms"
  create                  = var.create
  deletion_window_in_days = var.deletion_window_in_days
  description             = var.description
  enable_key_rotation     = var.enable_key_rotation
  aliases                 = var.aliases
  tags                    = var.tags

}

#------------------------------- SNS ---------------------------#
module "sns" {
  source            = "./ceq_tf_template_aws_sns"
  for_each          = var.sns_variable
  create            = var.create
  name              = each.value.sns_topic_name
  kms_master_key_id = module.kms.key_id
  subscriptions     = each.value.subscriptions
  tags              = var.tags


}
#---------------------------------Cloudtrail Bucket Pilicy------------------------#
data "aws_iam_policy_document" "cloudtrail_policy" {
  for_each = { for k, v in var.s3_variable : k => v if k == "cloudtrail" }
  statement {
    sid = "Allow PutObject"
    actions = [
      "s3:PutObject"
    ]

    resources = ["arn:aws:s3:::${each.value.bucket_name}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    }
  statement {
    sid = "Allow GetBucketLocation"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = ["arn:aws:s3:::${each.value.bucket_name}"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
  }

#-------------------------- Gurad Duty Bucket Policy--------------------------#
# data "aws_iam_policy_document" "guardduty_policy" {
#  for_each = { for k, v in var.s3_variable : k => v if k == "guard_duty" }
#   statement {
#     sid = "Allow PutObject"
#     actions = [
#       "s3:PutObject"
#     ]

#     resources = [
#       "arn:aws:s3:::${each.value.bucket_name}/*"
#     ]

#     principals {
#       type        = "Service"
#       identifiers = ["guardduty.amazonaws.com"]
#     }
#     condition {
#       test     = "StringLike"
#       variable = "s3:x-amz-acl"
#       values   = ["bucket-owner-full-control"]
#     }
#   }

#   statement {
#     sid = "Allow GetBucketLocation"
#     actions = [
#       "s3:GetBucketLocation",
#       "s3:GetBucketAcl",
#       "s3:ListBucket"
#     ]

#     resources = [
#       "arn:aws:s3:::${each.value.bucket_name}"

#     ]

#     principals {
#       type        = "Service"
#       identifiers = ["guardduty.amazonaws.com"]
#     }
#   }
# }

#-------------------------------Config Bucket Policy-----------------------------#
data "aws_iam_policy_document" "config_policy" {
    for_each = { for k, v in var.s3_variable : k => v if k == "config" }
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${each.value.bucket_name}"]

    #condition {
      #test     = "ArnEquals"
     # variable = "aws:PrincipalArn"
    #  values   = ["${module.Config.config_recorder_role}"]
   # }
  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${each.value.bucket_name}"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = ["${module.config.config_recorder_role}"]
    }
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl"
    ]

    resources = ["arn:aws:s3:::${each.value.bucket_name}/*"]

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    #condition {
     # test     = "ArnEquals"
    #  variable = "aws:PrincipalArn"
   #   values   = ["${module.Config.config_recorder_role}"]
    #}
  }
}


#--------------------------------------------S3------------------------------------#
module "s3" {
  source = "./ceq_tf_template_aws_s3"
  for_each = var.s3_variable
  bucket =  each.value.bucket_name
  force_destroy = each.value.force_destroy
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms.key_id
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
  attach_policy = true
  policy        = each.key == "cloudtrail" ? data.aws_iam_policy_document.cloudtrail_policy["cloudtrail"].json : each.key == "guard_duty" ? data.aws_iam_policy_document.guardduty_policy["guard_duty"].json : each.key == "config" ? data.aws_iam_policy_document.config_policy["config"].json : ""
}

#------------------------------------ Guard Duty---------------------------------#

# module "guardduty" {
#   source                           = "./ceq_tf_template_aws_guardduty"
#   depends_on                       = [module.kms]
#     providers = { 
#     aws = aws,
#     aws.delegated_admin = aws.delegated_admin # Use the delegated_admin provider for this module
#   }
#   member_accounts                  = var.member_accounts
#   guardduty_enable                 = var.guardduty_enable
#   finding_publishing_frequency     = var.finding_publishing_frequency
#   admin_account_id                 = var.admin_account_id
#   auto_enable_organization_members = var.auto_enable_organization_members
#   invite                           = var.invite
#   invitation_message               = var.invitation_message
#   disable_email_notification       = var.disable_email_notification
#   enable_s3_logs                   = var.enable_s3_logs
#   enable_kubernetes_audit_logs     = var.enable_kubernetes_audit_logs
#   enable_ebs_volumes_scan          = var.enable_ebs_volumes_scan
#   create_additional_feature        = var.create_additional_feature
#   additional_feature_name          = var.additional_feature_name
#   additional_configuration_name    = var.additional_configuration_name
#   gd_publishing_dest_bucket_arn    = module.s3["guard_duty"].s3_bucket_arn
#   gd_kms_key_arn                   = module.kms.key_arn
#   management_acc_email = var.management_acc_email
#   management_acc = var.management_acc
# }

#--------------------------------------Billing Alarm-------------------------------#
module "billing_alarm" {
  source              = "./ceq_tf_template_aws_billing-alarm"
  alarm_name          = var.alarm_name
  comparison_operator = var.billing_comparison_operator
  evaluation_periods  = var.billing_evaluation_periods
  metric_name         = var.billing_metric_name
  namespace           = var.namespace
  period              = var.billing_period
  statistic           = var.billing_statistic
  monthly_billing_threshold             = var.monthly_billing_threshold
  threshold_metric_id                   = var.threshold_metric_id
  actions_enabled                       = var.actions_enabled
  datapoints_to_alarm                   = var.datapoints_to_alarm
  insufficient_data_actions             = var.insufficient_data_actions
  ok_actions                            = var.ok_actions
  unit                                  = var.unit
  extended_statistic                    = var.extended_statistic
  treat_missing_data                    = var.treat_missing_data
  evaluate_low_sample_count_percentiles = var.evaluate_low_sample_count_percentiles
  alarm_description = var.billing_alarm_description
  currency          = var.currency
  #email_addresses   = var.email_addresses
  #kms_master_key_id = module.kms.key_arn
  protocol          = var.protocol
  alarm_actions     = [module.sns["billing_alarm"].topic_arn]
  tags = var.tags
}



#----------------Security Hub---------------------------#
module "security_hub" {
  source             = "./ceq_tf_template_aws_security_hub"
  delegated_admin_id = var.delegated_admin_id  # Pass the delegated admin ID as a variable
  providers = { 
    aws = aws,
    aws.delegated_admin = aws.delegated_admin # Use the delegated_admin provider for this module
  }
  member_account_ids = var.member_account_ids
  enable_default_standards  = var.enable_default_standards
  auto_enable_controls        = var.auto_enable_controls
  auto_enable_security_hub    = var.auto_enable_security_hub
  tags                         = var.tags
}



#---------------------Config Module---------------------------#
module "config" {
  source                                      = "./ceq_tf_template_aws_config"
  is_aggregator                               =  false
  create_iam_role                             = var.create_iam_role
  name                                        = var.config_name
  sns_topic_arn                               = module.sns["config"].topic_arn
  iam_role_arn                                = var.iam_role_arn
  create_organization_aggregator_iam_role     = var.create_organization_aggregator_iam_role
  iam_role_organization_aggregator_arn        = var.iam_role_organization_aggregator_arn
  global_resource_collector_region            = var.global_resource_collector_region
  central_resource_collector_account          = var.central_resource_collector_account
  is_organization_aggregator                  = true
  is_organization_aggregator_child            = false
  organization_aggregation_source             = var.organization_aggregation_source
  is_aws_config_configuration_recorder_create = var.is_aws_config_configuration_recorder_create
  recording_group                             = var.recording_group
  recording_mode                              = var.recording_mode
  account_aggregation_source                  = var.account_aggregation_source
  child_resource_collector_accounts           = var.child_resource_collector_accounts
  delivery_bucket_name                        = var.delivery_bucket_name
  delivery_frequency                          = var.delivery_frequency
  create_delivery_channel                     = var.create_delivery_channel
  create_config_rule                          = var.create_config_rule
  managed_rules                               = var.managed_rules
  s3_kms_key_arn                              = module.kms.key_arn
  lambda_arn                                  = var.lambda_arn
  all_regions                                 = var.all_regions
  regions                                     = var.config_regions
  retention_period                            = var.retention_period
  create_recorder_status                      = var.create_recorder_status
  tags                                        = var.tags
}


module "child-config" {
  source                                      = "./ceq_tf_template_aws_config"
  providers = {
    aws = aws.delegated_admin
    }
  create_iam_role                             = var.create_iam_role
  name                                        = var.config_name
  sns_topic_arn                               = module.sns["config"].topic_arn
  iam_role_arn                                = var.iam_role_arn
  create_organization_aggregator_iam_role     = var.create_organization_aggregator_iam_role
  iam_role_organization_aggregator_arn        = var.iam_role_organization_aggregator_arn
  global_resource_collector_region            = var.global_resource_collector_region
  central_resource_collector_account          = var.central_resource_collector_account
  is_organization_aggregator                  = true
  organization_aggregation_source             = var.organization_aggregation_source
  is_aws_config_configuration_recorder_create = var.is_aws_config_configuration_recorder_create
  recording_group                             = var.recording_group
  recording_mode                              = var.recording_mode
  account_aggregation_source                  = var.account_aggregation_source
  child_resource_collector_accounts           = var.child_resource_collector_accounts
  delivery_bucket_name                        = var.delivery_bucket_name
  delivery_frequency                          = var.delivery_frequency
  create_delivery_channel                     = var.create_delivery_channel
  create_config_rule                          = var.create_config_rule
  managed_rules                               = var.managed_rules
  s3_kms_key_arn                              = module.kms.key_arn
  lambda_arn                                  = var.lambda_arn
  all_regions                                 = var.all_regions
  regions                                     = var.config_regions
  retention_period                            = var.retention_period
  create_recorder_status                      = var.create_recorder_status
  tags                                        = var.tags
}










  
