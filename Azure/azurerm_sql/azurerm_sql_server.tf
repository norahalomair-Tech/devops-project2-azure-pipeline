locals {
  sql_private_endpoint_enabled = var.enable_private_endpoint
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password


  public_network_access_enabled = !local.sql_private_endpoint_enabled

  minimum_tls_version = "1.2"
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "sql" {
  count               = local.sql_private_endpoint_enabled ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  count                 = local.sql_private_endpoint_enabled ? 1 : 0
  name                  = "${var.sql_server_name}-dnslink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql[0].name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_endpoint" "sql" {
  count               = local.sql_private_endpoint_enabled ? 1 : 0
  name                = "${var.sql_server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.sql_server_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "${var.sql_server_name}-pdz"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.sql[0].id,
    ]
  }
}
