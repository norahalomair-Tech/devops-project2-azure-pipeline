module "resource_group" {
  source   = "../Azure/azurerm_resource_group"
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

module "vnet" {
  source              = "../Azure/azurerm_virtual_network"
  name                = local.vnet_name
  resource_group_name = module.resource_group.resource_group.name
  location            = local.location
  address_space       = local.address_space
  tags                = local.tags
}

module "nsgs" {
  source   = "../Azure/azurerm_network_security_group"
  for_each = local.nsgs

  name                = each.value.name
  resource_group_name = module.resource_group.name
  location            = local.location
  security_rules      = each.value.security_rules
}

module "subnets" {
  source                           = "../Azure/azurerm_subnets"
  for_each                         = local.subnet
  name                             = try(each.value.name, each.key)
  resource_group_name              = module.resource_group.resource_group.name
  vnet_name                        = module.vnet.virtual_network.name
  address_prefixes                 = each.value.address_space
  service_endpoints                = try(each.value.service_endpoints, [])
  delegation                       = try(each.value.delegation, null)
  associate_network_security_group = contains(keys(local.nsgs), each.key)
  network_security_group_id        = contains(keys(local.nsgs), each.key) ? module.nsgs[each.key].id : null
}

module "app_insights" {
  source = "../Azure/azurerm_application_insights"

  name                = "project2-norah-ai"
  location            = local.location
  resource_group_name = module.resource_group.resource_group.name
  tags                = local.tags
}

module "webapp" {
  source              = "../Azure/azurerm_webapp"
  resource_group_name = module.resource_group.name
  location            = local.location

  # Frontend
  service_plan_name_fe = "frontend-plan-norah"
  fe_app_name          = "burger-frontend-norah"
  fe_image_name        = "norah505/burger-frontend"
  fe_tag               = "latest"
  fe_sku               = "P1v2"
  public_access        = true

  # Backend
  service_plan_name_be = "backend-plan-norah"
  be_app_name          = "burger-backend-norah"
  be_image_name        = "norah505/burger-backend"
  be_tag               = "latest"
  be_sku               = "P1v2"

  sql_admin_password = var.sql_admin_password

  application_insights_connection_string   = module.app_insights.connection_string
  application_insights_instrumentation_key = module.app_insights.instrumentation_key

  frontend_subnet_id = module.subnets["frontend"].subnet_id
  backend_subnet_id  = module.subnets["backend"].subnet_id

  frontend_allowed_subnet_id = module.subnets["appgw_subnet"].subnet_id
  backend_allowed_subnet_id  = module.subnets["appgw_subnet"].subnet_id

  frontend_allowed_ip_address = format("%s/32", module.app_gateway.app_gateway_public_ip)
  backend_allowed_ip_address  = format("%s/32", module.app_gateway.app_gateway_public_ip)
}

module "sql" {
  source = "../Azure/azurerm_sql"

  resource_group_name = module.resource_group.name
  location            = local.location

  sql_server_name    = "burger-sqlserver-norah"
  sql_database_name  = "burgerdb"
  sql_admin_username = "norah"
  sql_admin_password = var.sql_admin_password

  tags = local.tags

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.subnets["sql"].subnet_id
  virtual_network_id         = module.vnet.virtual_network.id
}

module "app_gateway" {
  source = "../Azure/azurerm_app_gateway"

  prefix              = "burger-norah"
  location            = local.location
  resource_group_name = module.resource_group.resource_group.name
  subnet_id           = module.subnets["appgw_subnet"].subnet_id
  frontend_fqdn       = module.webapp.frontend_hostname
  backend_fqdn        = module.webapp.backend_hostname
}
