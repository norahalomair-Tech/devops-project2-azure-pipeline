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

variable "frontend_url" {
  type        = string
  description = "Public URL for frontend availability test (via App Gateway)"
  default     = null
}

variable "backend_url" {
  type        = string
  description = "Public URL for backend availability test (via App Gateway)"
  default     = null
}

variable "availability_threshold" {
  type        = number
  description = "Availability percentage threshold for alerts"
  default     = 99
}

variable "sql_failure_rate_threshold" {
  type        = number
  description = "Failure rate threshold (%) for SQL dependency alert"
  default     = 5
}

variable "action_group_id" {
  type        = string
  description = "Action Group resource ID for alert notifications"
  default     = null
}
