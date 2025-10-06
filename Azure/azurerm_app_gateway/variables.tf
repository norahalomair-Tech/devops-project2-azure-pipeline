variable "prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the App Gateway"
}

variable "frontend_fqdn" {
  type        = string
  description = "Frontend Web App FQDN"
}

variable "backend_fqdn" {
  type        = string
  description = "Backend Web App FQDN"
}

variable "public_ip_id" {
  type        = string
  description = "Public IP resource ID used by the Application Gateway"
}
