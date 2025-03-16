variable "tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
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
  description = "The AWS region to create resources in."
  type        = string
  default     = "config.amazonaws.com"
}

variable "organizational_units" {
  description = "A map of organizational units to create."
  type        = map(object({
    parent_name = string
    tags        = map(string)
  }))
}

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "aws_service_access_principals" {
  description = "Set of AWS service access principals to enable trusted access"
  type        = set(string)
}

