variable "scp_policies" {
  type = list(object({
    name        = string
    description = string
    content     = string
    target_ids  = string
  }))
}

variable "tags" {
  description = "Tags to apply to the SCP policies"
  type        = map(any)
  default     = {}
}
