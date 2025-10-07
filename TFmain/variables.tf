variable "frontend_url" {
  type        = string
  description = "Public URL for frontend availability test"
  default     = "https://fe-project2-aalhatlan.azurewebsites.net/"
}

variable "backend_url" {
  type        = string
  description = "Public URL for backend availability test"
  default     = "https://be-project2-aalhatlan.azurewebsites.net/api/health"
}

variable "action_group_id" {
  type        = string
  description = "Azure Monitor Action Group resource ID for alerts"
  default     = null
}
