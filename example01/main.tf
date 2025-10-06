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

module "subnets" {
  source              = "../Azure/azurerm_subnets"
  for_each            = local.subnet
  name                = try(each.value.name, each.key)
  resource_group_name = module.resource_group.resource_group.name
  vnet_name           = module.vnet.virtual_network.name
  address_prefixes    = each.value.address_space
  service_endpoints   = try(each.value.service_endpoints, [])
  delegation          = try(each.value.delegation, null)
}


module "webapp" {
  source              = "../Azure/azurerm_webapp"
  resource_group_name = module.resource_group.name
  location            = local.location

  # Frontend
  service_plan_name_fe = "plan"
  fe_app_name          = "fe-project2-aalhatlan"
  fe_image_name        = "aalhatlan/project2-fe"
  fe_tag               = "latest"
  fe_sku               = "P1v2"
  public_access        = true

  # Backend
  service_plan_name_be = "backend-plan"
  be_app_name          = "be-project2-aalhatlan"
  be_image_name        = "aalhatlan/project2-be"
  be_tag               = "latest"
  be_sku               = "P1v2"

  sql_admin_password = var.sql_admin_password

  frontend_subnet_id = module.subnets["frontend"].subnet_id
  backend_subnet_id  = module.subnets["backend"].subnet_id
}


module "sql" {
  source = "../Azure/azurerm_sql"

  resource_group_name = module.resource_group.name
  location            = local.location

  sql_server_name    = "project2-sqlserver-aalhatlan"
  sql_database_name  = "project2db"
  sql_admin_username = "ahmad"
  sql_admin_password = var.sql_admin_password

  tags = local.tags

  private_endpoint_subnet_id = module.subnets["sql"].subnet_id
  virtual_network_id         = module.vnet.virtual_network.id
}

module "app_gateway" {
  source = "../Azure/azurerm_app_gateway"

  prefix              = "project2"
  location            = local.location
  resource_group_name = module.resource_group.resource_group.name
  subnet_id           = module.subnets["appgw_subnet"].subnet_id
  frontend_fqdn       = module.webapp.frontend_hostname
  backend_fqdn        = module.webapp.backend_hostname
}
