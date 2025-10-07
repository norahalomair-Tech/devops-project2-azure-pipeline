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

variable "action_group_id" {
  type        = string
  description = "Azure Monitor Action Group resource ID for alerts"
  default     = null
}

