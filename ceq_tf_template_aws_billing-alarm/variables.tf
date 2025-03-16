variable "period" {
  type        = string
  default     = "21600" # 6 hours
  description = "The length of time in seconds to evaluate the metric over. This is used as the period for the alarm."
}

#   variable "email_addresses" {
#   type        = list(string)
#   description = "The email addresses to notify when the alarm is triggered."
#   default     = [""]
# }

variable "monthly_billing_threshold" {
  type        = number
  description = "The threshold value for estimated charges that will trigger the alarm."
  default     = 100.0
}
variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the CloudWatch alarm."
  default = {
    Terraform = "true"
    ManagedBy = "terraform"
  }
}

variable "threshold_metric_id" {
type = string
}

variable "actions_enabled" {
type = bool
}

variable "datapoints_to_alarm" {
type = number
}

variable "insufficient_data_actions" {
type = list(string)
}

variable "ok_actions" {
type = list(string)
}

variable "unit" {
type = any
}

variable "extended_statistic" {
type = string
}

variable "treat_missing_data" {
type = string
}

variable "evaluate_low_sample_count_percentiles" {
type = string
}


#=============================#
# SNS                         #
#=============================#
variable "create_sns_topic" {
  description = "Creates a SNS Topic if `true`."
  type        = bool
  default     = true
}


variable "alarm_actions" {
  description = "List of SNS topic ARNs to be used. If `create_sns_topic` is `true`, it merges the created SNS Topic by this module with this list of ARNs"
  type        = list(string)
  
}




variable "alarm_name" {
  type = string
}

variable "comparison_operator" {
  type = string
}

variable "evaluation_periods" {
  type = string
}

variable "metric_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "statistic" {
  type = string
}

variable "alarm_description" {
  type = string
}

variable "currency" {
  type = string
}


variable "protocol" {
  type = string
}


