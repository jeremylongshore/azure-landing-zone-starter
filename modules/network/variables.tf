variable "name_prefix" {
  description = "Prefix for resource names (e.g. alz-dev)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "hub_address_space" {
  type = list(string)
}

variable "hub_app_subnet_prefix" {
  type = string
}

variable "hub_data_subnet_prefix" {
  type = string
}

variable "spoke_address_space" {
  type = list(string)
}

variable "spoke_subnet_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
