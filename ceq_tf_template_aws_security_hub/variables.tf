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

#variable "control_finding_generator" {
  #description = "Control finding generator for Security Hub"
  #type        = string
  #default     = "default"  # Set a default value if applicable
#}
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


variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

