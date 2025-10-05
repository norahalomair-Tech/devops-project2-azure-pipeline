
resource "azurerm_service_plan" "frontend_plan" {
  name     = var.service_plan_name_fe
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name = var.fe_sku

}


resource "azurerm_linux_web_app" "frontend_app" {
  name                = var.fe_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.frontend_plan.id
  public_network_access_enabled = var.public_access

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "${var.fe_image_name}:${var.fe_tag}"
      docker_registry_url = "https://index.docker.io"
    }

    health_check_path                 = "/"
    health_check_eviction_time_in_min = 5
  }

  
  
}
