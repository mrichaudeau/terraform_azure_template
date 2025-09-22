# Monitoring module for Application Insights and Log Analytics

# Log Analytics Workspace
resource "azurecaf_name" "log_analytics" {
  name          = var.project_name
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.environment_name]
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = azurecaf_name.log_analytics.result
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb

  tags = var.tags
}

# Application Insights
resource "azurecaf_name" "application_insights" {
  name          = var.project_name
  resource_type = "azurerm_application_insights"
  suffixes      = [var.environment_name]
}

resource "azurerm_application_insights" "main" {
  name                = azurecaf_name.application_insights.result
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  retention_in_days   = var.app_insights_retention_days
  sampling_percentage = var.sampling_percentage

  tags = var.tags
}

# Action Groups for Alerts (optional)
resource "azurecaf_name" "action_group" {
  count         = length(var.alert_email_addresses) > 0 ? 1 : 0
  name          = var.project_name
  resource_type = "azurerm_monitor_action_group"
  suffixes      = [var.environment_name]
}

resource "azurerm_monitor_action_group" "main" {
  count               = length(var.alert_email_addresses) > 0 ? 1 : 0
  name                = azurecaf_name.action_group[0].result
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.project_name, "-", ""), 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# Application Insights Smart Detection (built-in alerts)
resource "azurerm_application_insights_smart_detection_rule" "failure_anomalies" {
  name                    = "Failure Anomalies - ${azurecaf_name.application_insights.result}"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.enable_smart_detection
}

# Custom Alert Rules
resource "azurerm_monitor_metric_alert" "cpu_percentage" {
  count               = var.enable_alerts ? 1 : 0
  name                = "cpu-percentage-${azurecaf_name.application_insights.result}"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "Alert when CPU percentage is greater than 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  dynamic "action" {
    for_each = azurerm_monitor_action_group.main
    content {
      action_group_id = action.value.id
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "memory_percentage" {
  count               = var.enable_alerts ? 1 : 0
  name                = "memory-percentage-${azurecaf_name.application_insights.result}"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "Alert when Memory percentage is greater than 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  dynamic "action" {
    for_each = azurerm_monitor_action_group.main
    content {
      action_group_id = action.value.id
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "response_time" {
  count               = var.enable_alerts ? 1 : 0
  name                = "response-time-${azurecaf_name.application_insights.result}"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "Alert when average response time is greater than 5 seconds"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5
  }

  dynamic "action" {
    for_each = azurerm_monitor_action_group.main
    content {
      action_group_id = action.value.id
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "http_5xx_errors" {
  count               = var.enable_alerts ? 1 : 0
  name                = "http-5xx-errors-${azurecaf_name.application_insights.result}"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "Alert when HTTP 5xx errors exceed 10 in 5 minutes"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  dynamic "action" {
    for_each = azurerm_monitor_action_group.main
    content {
      action_group_id = action.value.id
    }
  }

  tags = var.tags
}