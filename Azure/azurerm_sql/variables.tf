variable "resource_group_name" {
  type        = string
  description = "Resource group for SQL server"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "sql_server_name" {
  type        = string
  description = "Name of the SQL Server"
}

variable "sql_database_name" {
  type        = string
  description = "Name of the SQL Database"
}

variable "sql_admin_username" {
  type        = string
  description = "SQL administrator username"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL administrator password"
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID where the SQL private endpoint will be created"
  default     = null
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network ID used for DNS zone linkage"
  default     = null
}

variable "private_dns_zone_name" {
  type        = string
  description = "Private DNS zone name for SQL private endpoint"
  default     = "privatelink.database.windows.net"
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint and related DNS resources for the SQL Server"
  default     = false
}
