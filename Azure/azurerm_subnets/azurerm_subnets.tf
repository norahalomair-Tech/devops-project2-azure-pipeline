resource "azurerm_subnet" "subnet" {
  resource_group_name  = var.resource_group_name
  name                 = var.name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
  service_endpoints    = var.service_endpoints

  dynamic "delegation" {
    for_each = var.delegation == null ? [] : [var.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = var.associate_network_security_group ? 1 : 0

  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = var.network_security_group_id
}
