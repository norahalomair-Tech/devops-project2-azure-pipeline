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

