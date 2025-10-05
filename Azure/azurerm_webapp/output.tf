output "frontend_hostname" {
  value = azurerm_linux_web_app.frontend_app.default_hostname
}

output "backend_hostname" {
  value = azurerm_linux_web_app.backend_app.default_hostname
}
