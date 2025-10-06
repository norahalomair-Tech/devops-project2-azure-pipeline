variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "name" {
  description = "Subnet name"
}

variable "vnet_name" {
  description = "Name of the virtual network"
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet"
  default     = []
}

variable "service_endpoints" {
  description = "Service endpoints to associate with the subnet"
  type        = list(string)
  default     = []
}

variable "delegation" {
  description = "Optional delegation configuration for the subnet"
  type        = any
  default     = null
}

variable "network_security_group_id" {
  description = "Optional Network Security Group ID to associate with the subnet"
  type        = string
  default     = null
}

variable "associate_network_security_group" {
  description = "Flag indicating whether to associate an NSG with the subnet"
  type        = bool
  default     = false
}

