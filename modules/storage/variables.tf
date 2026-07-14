variable "name_prefix" {
  description = "Prefix for resource names (e.g. alz-dev)."
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
