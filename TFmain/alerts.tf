resource "azurerm_monitor_metric_alert" "app_gateway_backend_health" {
  name                = "appgw-backend-health-alert"
  resource_group_name = module.resource_group.name
  scopes              = [module.app_gateway.app_gateway_id]
  description         = "Alerts when the Application Gateway backend health drops below 100% for 5 minutes."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }
}
