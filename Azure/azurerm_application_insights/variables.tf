variable "name" {
  type        = string
  description = "Name of the Application Insights resource"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags"
  default     = {}
}

