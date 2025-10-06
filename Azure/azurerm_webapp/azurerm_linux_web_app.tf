
# 🟦 Frontend Service Plan + Web App


resource "azurerm_service_plan" "frontend_plan" {
  name                = var.service_plan_name_fe
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.fe_sku
}

resource "azurerm_linux_web_app" "frontend_app" {
  name                          = var.fe_app_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.frontend_plan.id
  virtual_network_subnet_id     = var.frontend_subnet_id
  public_network_access_enabled = var.public_access

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "${var.fe_image_name}:${var.fe_tag}"
      docker_registry_url = "https://index.docker.io"
    }

    health_check_path                 = "/"
    health_check_eviction_time_in_min = 5

    ip_restriction_default_action = var.frontend_allowed_subnet_id == null ? "Allow" : "Deny"

    dynamic "ip_restriction" {
      for_each = var.frontend_allowed_subnet_id == null ? [] : [var.frontend_allowed_subnet_id]

      content {
        name                      = "allow-appgateway"
        priority                  = 100
        action                    = "Allow"
        virtual_network_subnet_id = ip_restriction.value
      }
    }
  }
}


# 🟧 Backend Service Plan + Web App

resource "azurerm_service_plan" "backend_plan" {
  name                = var.service_plan_name_be
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.be_sku
}

resource "azurerm_linux_web_app" "backend_app" {
  name                          = var.be_app_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.backend_plan.id
  virtual_network_subnet_id     = var.backend_subnet_id
  public_network_access_enabled = var.public_access

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "${var.be_image_name}:${var.be_tag}"
      docker_registry_url = "https://index.docker.io"
    }

    health_check_path                 = "/api/health"
    health_check_eviction_time_in_min = 5

    ip_restriction_default_action = var.backend_allowed_subnet_id == null ? "Allow" : "Deny"

    dynamic "ip_restriction" {
      for_each = var.backend_allowed_subnet_id == null ? [] : [var.backend_allowed_subnet_id]

      content {
        name                      = "allow-appgateway"
        priority                  = 100
        action                    = "Allow"
        virtual_network_subnet_id = ip_restriction.value
      }
    }
  }

  app_settings = {
    "SPRING_PROFILES_ACTIVE" = "azure"
    "DB_HOST"                = "project2-sqlserver-aalhatlan.database.windows.net"
    "DB_PORT"                = "1433"
    "DB_NAME"                = "project2db"
    "DB_USERNAME"            = "ahmad"
    "DB_PASSWORD"            = var.sql_admin_password
    "DB_DRIVER"              = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
  }

}
