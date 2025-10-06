variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Location for the resource group"
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet"
  default     = []
}

variable "fe_image_name" {
  type        = string
  description = "(Frontend Docker image name)"
}

variable "fe_tag" {
  type        = string
  description = " (Frontend Docker image tag)"
  default     = "latest"
}
variable "fe_app_name" {
  type        = string
  description = " Azure"
}

variable "service_plan_name_fe" {
  type        = string
  description = " (App Service Plan) "
}

variable "fe_sku" {
  type        = string
  description = " (SKU)  P1v2  S1"
  default     = "P1v2"
}

variable "public_access" {
  type        = bool
  description = " access"
  default     = true
}

variable "be_app_name" {
  type        = string
  description = " Backend  Azure"
}

variable "service_plan_name_be" {
  type        = string
  description = "plan Backend"
}

variable "be_sku" {
  type        = string
  description = "SKU  Backend"
  default     = "P1v2"
}

variable "be_image_name" {
  type        = string
  description = "image Docker  Backend"
}

variable "be_tag" {
  type        = string
  description = "Tag  Docker Backend"
  default     = "latest"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL administrator password"
  sensitive   = true
}

variable "frontend_subnet_id" {
  description = "Subnet ID used for frontend web app VNet integration"
  type        = string
  default     = null
}

variable "backend_subnet_id" {
  description = "Subnet ID used for backend web app VNet integration"
  type        = string
  default     = null
}

variable "frontend_allowed_subnet_id" {
  description = "Subnet allowed to access the frontend web app"
  type        = string
  default     = null
}

variable "backend_allowed_subnet_id" {
  description = "Subnet allowed to access the backend web app"
  type        = string
  default     = null
}

variable "frontend_allowed_ip_address" {
  description = "IP address allowed to access the frontend web app"
  type        = string
  default     = null
}

variable "backend_allowed_ip_address" {
  description = "IP address allowed to access the backend web app"
  type        = string
  default     = null
}
