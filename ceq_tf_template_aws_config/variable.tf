#Default###########################################


variable "name" {
  type    = string
  default = "my-example"
}
variable "tags" {
  type = any
}

variable "sns_topic_arn" {
  type = string
  default = ""
}


variable "create_sns_topic" {
  type = bool
  default = false
}

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


variable "is_organization_aggregator_child" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config to send logs from organization accounts"
  type        = bool
  default     = true
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


#Bucket##################################

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  default     = true
}

variable "delivery_bucket_name" {
  description = "The name of the S3 bucket for AWS Config delivery channel"
  type        = string
  default     = "my-bucket-config-donotdelete"
}

variable "create_delivery_bucket" {
  description = "Specifies whether to create an S3 bucket for AWS Config delivery channel"
  type        = bool
  default     = true
}
variable "member_account_id" {
  description = "The AWS account ID for the bucket AWS Config delivery channel"
  type        = string
  default     = "864981756572"
}
variable "s3_kms_key_arn" {
  type = string
  default = ""
}





variable "s3_key_prefix" {
  type        = string
  description = <<-DOC
    The prefix for AWS Config objects stored in the the S3 bucket. If this variable is set to null, the default, no
    prefix will be used.

    Examples:

    with prefix:    {S3_BUCKET NAME}:/{S3_KEY_PREFIX}/AWSLogs/{ACCOUNT_ID}/Config/*.
    without prefix: {S3_BUCKET NAME}:/AWSLogs/{ACCOUNT_ID}/Config/*.
  DOC
  default     = null
}

#KMS##########################################################



#config#######################################################




variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
  default     = "us-east-1"
}

variable "central_resource_collector_account" {
  description = "The account ID of a central account that will aggregate AWS Config from other accounts"
  type        = string
  default     = ""
}

variable "child_resource_collector_accounts" {
  description = "The account IDs of other accounts that will send their AWS Configuration to this account"
  type        = set(string)
  default     = [ ]
}

variable "is_organization_aggregator" {
  type        = bool
  description = "The aggregator is an AWS Organizations aggregator"
  default = true
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

variable "regions" {
  type    = list(string)
  default = []
}

#aws_config_retention_configuration

variable "retention_period" {
  type    = number
  default = 30
}

# default





#recorder
variable "create_recorder_status" {
  type    = bool
  default = true
}

variable "is_aggregator" {
  type = bool
  default = true
}
