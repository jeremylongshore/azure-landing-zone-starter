variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "storage_account_id" {
  description = "Storage account resource ID for diagnostics and alerts."
  type        = string
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "alert_email" {
  description = "Optional email for action group. Empty string skips email receiver."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
