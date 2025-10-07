#  Frontend Service Plan + Web App

locals {
  frontend_ip_restrictions = [
    for rule in [
      var.frontend_allowed_subnet_id == null ? null : {
        name                      = "gw-subnet"
        priority                  = 300
        action                    = "Allow"
        virtual_network_subnet_id = var.frontend_allowed_subnet_id
      },
      var.frontend_allowed_ip_address == null ? null : {
        name       = "gw-ip"
        priority   = 310
        action     = "Allow"
        ip_address = var.frontend_allowed_ip_address
      }
    ] : rule if rule != null
  ]

  backend_ip_restrictions = [
    for rule in [
      var.backend_allowed_subnet_id == null ? null : {
        name                      = "gw-subnet"
        priority                  = 300
        action                    = "Allow"
        virtual_network_subnet_id = var.backend_allowed_subnet_id
      },
      var.backend_allowed_ip_address == null ? null : {
        name       = "gw-ip"
        priority   = 310
        action     = "Allow"
        ip_address = var.backend_allowed_ip_address
      }
    ] : rule if rule != null
  ]

  frontend_app_settings = var.application_insights_connection_string == null ? {} : {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.application_insights_instrumentation_key
    APPLICATIONINSIGHTS_ROLE_NAME         = var.frontend_app_insights_role_name
  }

  backend_app_settings = var.application_insights_connection_string == null ? {} : {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.application_insights_instrumentation_key
    APPLICATIONINSIGHTS_ROLE_NAME         = var.backend_app_insights_role_name
  }
}

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

  app_settings = local.frontend_app_settings

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "${var.fe_image_name}:${var.fe_tag}"
      docker_registry_url = "https://index.docker.io"
    }

    health_check_path                 = "/"
    health_check_eviction_time_in_min = 5

    dynamic "ip_restriction" {
      for_each = local.frontend_ip_restrictions

      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
        ip_address                = try(ip_restriction.value.ip_address, null)
      }
    }

    ip_restriction_default_action = length(local.frontend_ip_restrictions) == 0 ? "Allow" : "Deny"

  }
}


#  Backend Service Plan + Web App

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

    dynamic "ip_restriction" {
      for_each = local.backend_ip_restrictions

      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
        ip_address                = try(ip_restriction.value.ip_address, null)
      }
    }

    ip_restriction_default_action = length(local.backend_ip_restrictions) == 0 ? "Allow" : "Deny"

  }

  app_settings = merge({
    "SPRING_PROFILES_ACTIVE" = "azure"
    "DB_HOST"                = "project2-sqlserver-aalhatlan.database.windows.net"
    "DB_PORT"                = "1433"
    "DB_NAME"                = "project2db"
    "DB_USERNAME"            = "ahmad"
    "DB_PASSWORD"            = var.sql_admin_password
    "DB_DRIVER"              = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
  }, local.backend_app_settings)

}
