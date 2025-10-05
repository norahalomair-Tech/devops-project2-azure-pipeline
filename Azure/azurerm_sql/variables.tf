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
