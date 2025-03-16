variable "guardduty_enable" {
  type        = bool
  default     = true
  description = " Enable monitoring and feedback reporting. Setting to false is equivalent to suspending GuardDuty. Defaults to true"
}

variable "finding_publishing_frequency" {
  type        = string
  default     = "SIX_HOURS"
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences"
}

variable "member_accounts" {
  description = "Map of member account IDs to their email addresses."
  type        = map(object({
    email = string
  }))
}

variable "tags" {
  type = map(any)
  default = {

  }
}

variable "admin_account_id" {
  type        = string
  default     = "864981756572"
  description = "AWS account identifier to designate as a delegated administrator for GuardDuty."
}

variable "auto_enable_organization_members" {
  type        = string
  default     = "ALL"
  description = "Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization. Valid values are ALL, NEW, NONE"
}


variable "invite" {
  type        = bool
  default     = false
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
  default     = ""
  description = "The name of the additional configuration for a feature that will be configured for the organization. Valid values: EKS_ADDON_MANAGEMENT, ECS_FARGATE_AGENT_MANAGEMENT, EC2_AGENT_MANAGEMENT"
}

variable "management_acc_email" {
  type = string
}

variable "management_acc" {
  type = string
}
