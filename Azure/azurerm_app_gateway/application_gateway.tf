resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.prefix}-appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "${var.prefix}-app-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  backend_address_pool {
    name  = "frontend-backend-pool"
    fqdns = [var.frontend_fqdn]
  }

  backend_address_pool {
    name  = "backend-backend-pool"
    fqdns = [var.backend_fqdn]
  }

  backend_http_settings {
  name                  = "httpSettings"
  cookie_based_affinity = "Disabled"
  port                  = 443
  protocol              = "Https"
  request_timeout       = 60

  pick_host_name_from_backend_address = true
}


  http_listener {
    name                           = "appGatewayHttpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                = "main-routing-rule"
    rule_type           = "PathBasedRouting"
    priority            = 100
    http_listener_name  = "appGatewayHttpListener"
    url_path_map_name   = "backend-path-map"
  }

  url_path_map {
    name                               = "backend-path-map"
    default_backend_address_pool_name  = "frontend-backend-pool"
    default_backend_http_settings_name = "httpSettings"

    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-backend-pool"
      backend_http_settings_name = "httpSettings"
    }
  }
}
