
#-------------------Common Variables---------------------#
variable "region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
}

#-------------------ORGANIZATION VARIABLES-------------------#

variable "organizational_units" {
  description = "A map of organizational units to create."
  type        = map(object({
    parent_name = string
    tags        = map(string)
  }))
}

variable "aws_service_access_principals" {
  description = "Set of AWS service access principals to enable trusted access"
  type        = set(string)  # Ensure this matches the type in the parent
}


#--------------------SSO PERMISSION SETS --------------------------#
variable "permission_sets" {
  description = "List of permission sets"
  type = list(object({
    name             = string
    description      = string
    relay_state      = string
    session_duration = string
    #tags               = map(string)
    inline_policy      = string
    policy_attachments = list(string)
    customer_managed_policy_attachments = list(object({
      name = string
      path = optional(string, "/")
    }))
  }))

  default = []
}

#-------------------------Cloudtrail Variable----------------------------#

variable "name" {
  description = "Namespace to be used on all resources"
  type        = string
}

variable "s3_key_prefix" {
  description = "Specifies the S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  type        = string
  default     = null
}

variable "enable_cloudwatch_logs" {
  description = "Enables Cloudtrail logs to write to ceated log group."
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 365
}

variable "enable_logging" {
  description = "Enables logging for the trail. Defaults to true. Setting this to false will pause logging."
  type        = bool
  default     = false
}

variable "enable_log_file_validation" {
  description = "Specifies whether log file integrity validation is enabled."
  type        = bool
  default     = false
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files."
  type        = bool
  default     = false
}

variable "is_multi_region_trail" {
  description = "Specifies whether the trail is created in the current region or in all regions."
  type        = bool
  default     = false
}

variable "is_organization_trail" {
  description = "Specifies whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
  type        = bool
  default     = false
}

variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`"
  type        = number
  default     = 7
}

variable "aliases" {
  description = "A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values"
  type        = list(string)
  default     = ["wafr-cloudtrail-root"]
}

variable "description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = "The description of the key as viewed in AWS console"
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled. Defaults to `true`"
  type        = bool
  default     = true
}


variable "event_selectors" {
  description = "Specifies a list of event selectors for enabling data event logging. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#event_selector."

  type = list(object({
    read_write_type           = string
    include_management_events = bool

    data_resource = object({
      type   = string
      values = list(string)
    })
  }))

  default = []
}

variable "insight_selectors" {
  description = "Specifies a list of insight selectors for identifying unusual operational activity. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#insight_selector."

  type = list(object({
    insight_type = string
  }))

  default = []
}



############# Alert on cloudtrail root acoount logging #######



variable "alarm_namespace" {
  description = "Namespace for generated Cloudwatch alarms"
  type        = string
  default     = "CISBenchmark"
}

variable "alarm_prefix" {
  description = "Prefix for the alarm name"
  type        = string
  default     = ""
}

variable "root_usage" {
  description = "Toggle root usage alarm"
  type        = bool
  default     = true
}



variable "alarm_description" {
  type        = string
  description = "The description for the alarm."
  default     = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."

}

variable "threshold" {
  type        = number
  description = "This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models."
  default     = 1

}

variable "statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"
  default     = "Sum"

}

variable "period" {
  type        = number
  description = " The period in seconds over which the specified statistic is applied. Valid values are 10, 30, or any multiple of"
  default     = 300

}

variable "comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold. Additionally, the values LessThanLowerOrGreaterThanUpperThreshold, LessThanLowerThreshold, and GreaterThanUpperThreshold are used only for alarms based on anomaly detection models"
  default     = "GreaterThanOrEqualToThreshold"

}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 1

}

variable "metric_name" {
  type        = string
  description = "name of metric"
  default     = "RootUsage"

}


variable "s3_variable" {
  type = any
}


#------------------ Guard Duty Variable--------------------------#
variable "guardduty_enable" {
  type        = bool
  default     = true
  description = " Enable monitoring and feedback reporting. Setting to false is equivalent to suspending GuardDuty. Defaults to true"
}

variable "member_accounts" {
  description = "Map of member account IDs to their email addresses."
  type        = map(object({
    email = string
  }))
}

variable "finding_publishing_frequency" {
  type        = string
  default     = "SIX_HOURS"
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences"
}
variable "admin_account_id" {
  type        = string
  default     = ""
  description = "AWS account identifier to designate as a delegated administrator for GuardDuty."
}

variable "auto_enable_organization_members" {
  type        = string
  default     = "NEW"
  description = "Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization. Valid values are ALL, NEW, NONE"
}


variable "invite" {
  type        = bool
  default     = true
  description = "Boolean whether to invite the account to GuardDuty as a member. Defaults to false"
}

variable "invitation_message" {
  type        = string
  default     = ""
  description = "Message for invitation."
}

variable "disable_email_notification" {
  type        = bool
  default     = false
  description = "Boolean whether an email notification is sent to the accounts. Defaults to false."
}


variable "gd_publishing_dest_bucket_arn" {
  default     = ""
  type        = string
  description = "S3 bucket required for publishing"
}

variable "gd_kms_key_arn" {
  type        = string
  default     = ""
  description = "Required kms arn for aws_guardduty_publishing_destination"
}

variable "enable_s3_logs" {
  description = "Enable or disable S3 log collection"
  type        = bool
  default     = true
}

variable "enable_kubernetes_audit_logs" {
  description = "Enable or disable Kubernetes audit logs"
  type        = bool
  default     = false
}

variable "enable_ebs_volumes_scan" {
  description = "Enable or disable EBS volume scanning on EC2 instances with findings"
  type        = bool
  default     = true
}


variable "create_additional_feature" {
  type        = bool
  default     = false
  description = "Whether to create additional feature or not"
}

variable "additional_feature_name" {
  type        = list(string)
  default     = ["RDS_LOGIN_EVENTS"]
  description = "The name of the feature that will be configured for the organization. Valid values: S3_DATA_EVENTS, EKS_AUDIT_LOGS, EBS_MALWARE_PROTECTION, RDS_LOGIN_EVENTS, EKS_RUNTIME_MONITORING, LAMBDA_NETWORK_LOGS, RUNTIME_MONITORING. Only one of two features EKS_RUNTIME_MONITORING or RUNTIME_MONITORING can be added, adding both features will cause an error. "
}

variable "additional_configuration_name" {

  type        = string
  default     = "EKS_ADDON_MANAGEMENT"
  description = "The name of the additional configuration for a feature that will be configured for the organization. Valid values: EKS_ADDON_MANAGEMENT, ECS_FARGATE_AGENT_MANAGEMENT, EC2_AGENT_MANAGEMENT"
}
variable "sns_variable" {
  type = any
}

variable "management_acc_email" {
  type = string
description = "Email of management account"
}

variable "management_acc" {
type = string
}


#---------------------------- Billing_alarm_variables--------------------------------#

variable "billing_period" {
  type        = string
  default     = "21600" # 6 hours
  description = "The length of time in seconds to evaluate the metric over. This is used as the period for the alarm."
}

variable "monthly_billing_threshold" {
  type        = number
  description = "The threshold value for estimated charges that will trigger the alarm."
  default     = 100.0
}
variable "alarm_name" {
  type        = string
  description = "The name of alarm."
  default     = "Billing-alarm-threshhold"
}

#   variable "email_addresses" {
#   type        = list(string)
#   description = "The email addresses to notify when the alarm is triggered."
#   default     = [""]
# }

variable "billing_comparison_operator" {
  type        = string
  description = "Enter the operator for comparison like GreaterThan, LessThan"
}

variable "billing_evaluation_periods" {
  type        = string
  description = "The number of periods over which data is compared to the specified threshold"
}

variable "billing_metric_name" {
  type        = string
  description = "Name of the alarm's associated metric"
}

variable "namespace" {
  type        = string
  description = "Namespace of the alarm's associated metric"
}

variable "billing_statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric"
}

variable "billing_alarm_description" {
  type        = string
  default     = ""
  description = "alarm description"
}

variable "currency" {
  type        = string
  description = "The default currency of billing"
}

#variable "sns_topic_name" {
 # type        = string
  #description = "Name of sns topic"
#}

variable "protocol" {
  type        = string
  description = "On which protocol sns work i.e. email etc"
}

variable "threshold_metric_id" {
  type        = string
  default     = null
  description = " If this is an alarm based on an anomaly detection model, make this value match the ID of the ANOMALY_DETECTION_BAND function"
}

variable "actions_enabled" {
  type        = bool
  default     = true
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state. Defaults to true"
}

variable "datapoints_to_alarm" {
  type        = number
  default     = null
  description = "The number of datapoints that must be breaching to trigger the alarm"
}

variable "insufficient_data_actions" {
  type        = list(string)
  default     = null
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "ok_actions" {
  type        = list(string)
  default     = null
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "unit" {
  type        = any
  default     = null
  description = "The unit for the alarm's associated metric"
}

variable "extended_statistic" {
  type        = string
  default     = null
  description = " The percentile statistic for the metric associated with the alarm. Specify a value between p0.0 and p100."
}

variable "treat_missing_data" {
  type        = string
  default     = null
  description = "Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing."
}

variable "evaluate_low_sample_count_percentiles" {
  type        = string
  default     = null
  description = "Used only for alarms based on percentiles. If you specify ignore, the alarm state will not change during periods with too few data points to be statistically significant. If you specify evaluate or omit this parameter, the alarm will always be evaluated and possibly change state no matter how many data points are available. The following values are supported: ignore, and evaluate."
}


#-----------------------Security Hub Variables----------------------#
variable "delegated_admin_id" {
  description = "The account ID of the delegated admin."
  type        = string
}


variable "member_account_ids" {
  description = "List of AWS account IDs to be added as members to Security Hub."
  type        = list(string)
}

variable "enable_default_standards" {
  description = "Enable default security standards in Security Hub"
  type        = bool
  #default     = true  # Set a default value if applicable
}


variable "auto_enable_controls" {
  description = "Automatically enable relevant controls in Security Hub"
  type        = bool
  #default     = true  # Set a default value if applicable
}

variable "auto_enable_security_hub" {
  description = "Automatically enable Security Hub for new member accounts"
  type        = bool
  #default     = true  # Adjust as necessary
}

variable "scp_policies" {
  description = "Creating SCP Policies"
  type        = any
}


#-------------------------- Config Variables-------------------------------#
#Role###############################################

variable "create_iam_role" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = <<-DOC
    The ARN for an IAM Role AWS Config uses to make read or write requests to the delivery channel and to describe the
    AWS resources associated with the account. This is only used if create_iam_role is false.

    If you want to use an existing IAM Role, set the value of this to the ARN of the existing topic and set
    create_iam_role to false.

    See the AWS Docs for further information:
    http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
  DOC
  default     = null
  type        = string
}

#aggregator
variable "create_organization_aggregator_iam_role" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config to send logs from organization accounts"
  type        = bool
  default     = false
}



variable "iam_role_organization_aggregator_arn" {
  description = <<-DOC
    The ARN for an IAM Role that AWS Config uses for the organization aggregator that fetches AWS config data from AWS accounts. 
    This is only used if create_organization_aggregator_iam_role is false.

    If you want to use an existing IAM Role, set the value of this to the ARN of the existing role and set
    create_organization_aggregator_iam_role to false.

    See the AWS docs for further information:
    http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
  DOC
  default     = null
  type        = string
}

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
  default     = "us-east-1"
}

variable "central_resource_collector_account" {
  description = "The account ID of a central account that will aggregate AWS Config from other accounts"
  type        = string
  default     = "864981756572"
}

variable "child_resource_collector_accounts" {
  description = "The account IDs of other accounts that will send their AWS Configuration to this account"
  type        = set(string)
  default     = [ "061051258908" ]
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  default     = true
}

variable "organization_aggregation_source" {
  type = object({
    all_regions = bool
    role_arn = string
    #regions = list(string)
  })
  default = {
    all_regions = true
    role_arn = ""
    #regions = []
  }
}

variable "delegated_config" {
  description = "Whether delegated config account to create or not."
  type        = bool
  default     = false
}

variable "delegated_config_account" {
  description = "Delegated config account id."
  type        = string
  default     = "881490103380"
}


variable "service_principal_config" {
  description = "which service principal you want to delegate"
  type        = string
  default     = "config.amazonaws.com"
}

variable "account_aggregation_source" {
  type = object({
    account_ids = list(string)
    regions = list(string) 
  })
  default = {
    account_ids = [  ]
    regions = [ "us-east-1" ]
  }
}
# aws_config_configuration_recorder

variable "is_aws_config_configuration_recorder_create" {
  type    = bool
  default = true

}

variable "recording_group" {

  type = object({
    all_supported                 = bool
    include_global_resource_types = bool
    exclusion_by_resource_types = object({
      excluded_resource_type = list(string)
    })
    recording_strategy = object({
      use_only = string
    })
    resource_types = list(string)
  })
  default = {
    all_supported                 = true
    include_global_resource_types = true
    exclusion_by_resource_types = {
      excluded_resource_type = []
    }
    recording_strategy = {
      use_only = "NULL"
    }
    resource_types = [ ]
  }
}



variable "recording_mode" {
  description = <<-DOC
    The mode for AWS Config to record configuration changes. 

    recording_frequency:
    The frequency with which AWS Config records configuration changes (service defaults to CONTINUOUS).
    - CONTINUOUS
    - DAILY

    You can also override the recording frequency for specific resource types.
    recording_mode_override:
      description:
        A description for the override.
      recording_frequency:
        The frequency with which AWS Config records configuration changes for the specified resource types.
        - CONTINUOUS
        - DAILY
      resource_types:
        A list of resource types for which AWS Config records configuration changes. For example, AWS::EC2::Instance.
    
    See the following for more information:
    https://docs.aws.amazon.com/config/latest/developerguide/stop-start-recorder.html

    /*
    recording_mode = {
      recording_frequency = "DAILY"
      recording_mode_override = {
        description         = "Override for specific resource types"
        recording_frequency = "CONTINUOUS"
        resource_types      = ["AWS::EC2::Instance"]
      }
    }
    */
  DOC
  type = object({
    recording_frequency = string
    recording_mode_override = optional(object({
      description         = string
      recording_frequency = string
      resource_types      = list(string)
    }))
  })
  default = null
}



#aws_config_delivery_channel
variable "delivery_frequency" {
  type    = string
  default = "One_Hour"
}


variable "create_delivery_channel" {
  type    = bool
  default = true
}
#aws_config_config_rule

variable "create_config_rule" {
  type    = bool
  default = true
}

variable "managed_rules" {
  description = <<-DOC
    A list of AWS Managed Rules that should be enabled on the account.

    See the following for a list of possible rules to enable:
    https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
  DOC
  type = map(object({
    description                 = string
    identifier                  = string
    input_parameters            = any
    tags                        = map(string)
    enabled                     = bool
    evaluation_mode             = map(string)
    maximum_execution_frequency = string
    scope = object({
      compliance_resource_id    = string
      compliance_resource_types = list(string)
      tag_key                   = string
      tag_value                 = string
    })
    source = object({
      owner = string
      source_identifier = string
      source_detail = object({
        event_source                = string
        maximum_execution_frequency = string
        message_type                = string
      })
      custom_policy_details = object({
        enable_debug_log_delivery = string
        policy_runtime            = string
        policy_text               = string
      })
    })
  }))
  default = {}
}




variable "lambda_arn" {
  type = string
  default = ""
  description = "Lambda arn for custom lambda rules"
}

#aws_config_configuration_aggregator

variable "all_regions" {
  type    = string
  default = "true"
}

variable "config_regions" {
  type    = list(string)
  default = []
}

#aws_config_retention_configuration

variable "retention_period" {
  type    = number
  default = 30
}

# default


variable "config_name" {
  type    = string
  default = "my-example"
}


#recorder
variable "create_recorder_status" {
  type    = bool
  default = true
}

#bucket

variable "delivery_bucket_name" {
  description = "The name of the S3 bucket for AWS Config delivery channel"
  type        = string
  default     = ""
}

# variable "create_delivery_bucket" {
#   description = "Specifies whether to create an S3 bucket for AWS Config delivery channel"
#   type        = bool
#   default     = true
# }
variable "account_id" {
  description = "The AWS account ID for the bucket AWS Config delivery channel"
  type        = string
  default     = "061051258908"
}
