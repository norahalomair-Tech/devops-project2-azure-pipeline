output "sql_server_name" {
  value = azurerm_mssql_server.sql_server.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_db.name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_private_endpoint_ip" {
  value = try(azurerm_private_endpoint.sql[0].private_service_connection[0].private_ip_address, null)
}

output "sql_database_id" {
  value = azurerm_mssql_database.sql_db.id
}
