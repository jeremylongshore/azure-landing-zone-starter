variable "subscription_id" {
  description = "Azure subscription ID. Also accepted via ARM_SUBSCRIPTION_ID."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name used in resource naming (dev, test, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "project_name" {
  description = "Short project slug used in resource names (lowercase alphanumeric/hyphen)."
  type        = string
  default     = "alz"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.project_name))
    error_message = "project_name must be 2-12 chars: lowercase letters, digits, hyphens."
  }
}

variable "hub_address_space" {
  description = "CIDR for the hub VNet (app + data subnets)."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_app_subnet_prefix" {
  description = "CIDR for the hub app subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "hub_data_subnet_prefix" {
  description = "CIDR for the hub data subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "spoke_address_space" {
  description = "CIDR for the spoke VNet (on-prem connectivity stand-in)."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "spoke_subnet_prefix" {
  description = "CIDR for the spoke workload subnet."
  type        = string
  default     = "10.10.1.0/24"
}

variable "alert_email" {
  description = "Optional email for the monitor action group. Leave empty to skip email receiver."
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags merged onto all resources."
  type        = map(string)
  default     = {}
}
