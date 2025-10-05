# 🟦 Frontend Service Plan
resource "azurerm_service_plan" "frontend_plan" {
  name                = var.service_plan_name_fe
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.fe_sku
}

# 🟦 Frontend Web App
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

    # ✅ Access Restrictions (Frontend)
    ip_restriction {
      name        = "Allow-AppGateway"
      priority    = 100
      action      = "Allow"
      ip_address  = "4.210.178.108/32"   # ← IP القيت وي
      description = "Allow traffic only from Application Gateway"
    }

    ip_restriction {
      name        = "Deny-All"
      priority    = 200
      action      = "Deny"
      description = "Deny all other traffic"
    }
  }
}

# 🟧 Backend Service Plan
resource "azurerm_service_plan" "backend_plan" {
  name                = var.service_plan_name_be
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.be_sku
}

# 🟧 Backend Web App
resource "azurerm_linux_web_app" "backend_app" {
  name                = var.be_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.backend_plan.id
  public_network_access_enabled = var.public_access

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "${var.be_image_name}:${var.be_tag}"
      docker_registry_url = "https://index.docker.io"
    }

    health_check_path                 = "/api/health"
    health_check_eviction_time_in_min = 5

    # ✅ Access Restrictions (Backend)
    ip_restriction {
      name        = "Allow-AppGateway"
      priority    = 100
      action      = "Allow"
      ip_address  = "4.210.178.108/32"
      description = "Allow traffic only from Application Gateway"
    }

    ip_restriction {
      name        = "Deny-All"
      priority    = 200
      action      = "Deny"
      description = "Deny all other traffic"
    }
  }

  app_settings = {
    "SPRING_PROFILES_ACTIVE" = "azure"
    "DB_HOST"               = "project2-sqlserver-aalhatlan.database.windows.net"
    "DB_PORT"               = "1433"
    "DB_NAME"               = "project2db"
    "DB_USERNAME"           = "ahmad"
    "DB_PASSWORD"           = var.sql_admin_password
    "DB_DRIVER"             = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
  }
}

# 🌐 Outputs
output "frontend_url" {
  value = azurerm_linux_web_app.frontend_app.default_hostname
}

output "backend_url" {
  value = azurerm_linux_web_app.backend_app.default_hostname
}
