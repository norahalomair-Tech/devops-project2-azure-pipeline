output "subnet" {
  value = azurerm_subnet.subnet
}
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "app_gateway_subnet_id" {
  value = azurerm_subnet.app_gateway_subnet.id
}

