#############
# Web Tests #
#############

resource "azurerm_application_insights_standard_web_test" "fe_web_test" {
  count                   = var.frontend_url == null ? 0 : 1
  name                    = "fe-web-test"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.this.id

  enabled        = true
  frequency      = 300   # 5 minutes
  timeout        = 60    # 60 seconds
  geo_locations  = ["emea-nl-ams-azr", "emea-fr-pra-azr"]

  request {
    url       = var.frontend_url
    http_verb = "GET"
  }

  validation_rules {
    expected_status_code = 200
    ssl_check_enabled    = true
  }
}

resource "azurerm_application_insights_standard_web_test" "be_web_test" {
  count                   = var.backend_url == null ? 0 : 1
  name                    = "be-web-test"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.this.id

  enabled        = true
  frequency      = 300   # 5 minutes
  timeout        = 60    # 60 seconds
  geo_locations  = ["emea-nl-ams-azr", "emea-fr-pra-azr"]

  request {
    url       = var.backend_url
    http_verb = "GET"
  }

  validation_rules {
    expected_status_code = 200
    ssl_check_enabled    = true
  }
}

#################
# Metric Alerts #
#################

resource "azurerm_monitor_metric_alert" "fe_alert" {
  count               = var.frontend_url == null ? 0 : 1
  name                = "fe-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Frontend availability below threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold

    dimension {
      name     = "TestName"
      operator = "Include"
      values   = [azurerm_application_insights_standard_web_test.fe_web_test[0].name]
    }
  }

  dynamic "action" {
    for_each = var.action_group_id == null ? [] : [var.action_group_id]

    content {
      action_group_id = action.value
    }
  }
}

resource "azurerm_monitor_metric_alert" "be_alert" {
  count               = var.backend_url == null ? 0 : 1
  name                = "be-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Backend availability below threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold

    dimension {
      name     = "TestName"
      operator = "Include"
      values   = [azurerm_application_insights_standard_web_test.be_web_test[0].name]
    }
  }

  dynamic "action" {
    for_each = var.action_group_id == null ? [] : [var.action_group_id]

    content {
      action_group_id = action.value
    }
  }
}

#########################
# SQL Failure KQL Alert #
#########################

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "sql_failure_alert" {
  count                = 1
  name                 = "sql-failure-rate-alert"
  location             = var.location
  resource_group_name  = var.resource_group_name
  scopes               = [azurerm_application_insights.this.id]
  description          = "SQL dependency failure rate exceeds threshold"
  severity             = 2
  enabled              = true
  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"

  action {
    action_groups = var.action_group_id == null ? [] : [var.action_group_id]
  }

  criteria {
    query                    = <<-KQL
dependencies
| where type == "SQL"
| summarize total=count(), failed=countif(tostring(success) == "False") by bin(timestamp, 5m)
| extend failureRate = 100.0 * failed / total
| where total > 0 and failureRate > ${var.sql_failure_rate_threshold}
KQL
    operator                  = "GreaterThan"
    threshold                 = 0
    time_aggregation_method   = "Count"
  }
}
