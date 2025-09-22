# Monitoring Module - Application Insights and Log Analytics
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Azure Naming Module
module "naming" {
  source = "Azure/naming/azurerm"
  suffix = [var.project_name, var.environment]
}

# Resource Group for Monitoring
resource "azurerm_resource_group" "monitoring" {
  name     = "${module.naming.resource_group.name}-monitoring"
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = module.naming.log_analytics_workspace.name
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  
  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = module.naming.application_insights.name
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  
  tags = var.tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${module.naming.monitor_action_group.name}-alerts"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "fastapiag"
  
  # Email notifications
  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  # SMS notifications (if provided)
  dynamic "sms_receiver" {
    for_each = var.alert_sms_numbers
    content {
      name         = "sms-${sms_receiver.key}"
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }
  
  tags = var.tags
}

# App Service CPU Alert
resource "azurerm_monitor_metric_alert" "app_service_cpu" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${module.naming.monitor_metric_alert.name}-app-cpu"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.app_service_id]
  description         = "Alert when App Service CPU usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
  
  tags = var.tags
}

# App Service Memory Alert
resource "azurerm_monitor_metric_alert" "app_service_memory" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${module.naming.monitor_metric_alert.name}-app-memory"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.app_service_id]
  description         = "Alert when App Service memory usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
  
  tags = var.tags
}

# App Service Response Time Alert
resource "azurerm_monitor_metric_alert" "app_service_response_time" {
  count               = var.enable_alerts ? 1 : 0
  name                = "${module.naming.monitor_metric_alert.name}-app-response-time"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.app_service_id]
  description         = "Alert when App Service response time is high"
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
  
  tags = var.tags
}

# SQL Database DTU Alert
resource "azurerm_monitor_metric_alert" "sql_database_dtu" {
  count               = var.enable_alerts && var.sql_database_id != null ? 1 : 0
  name                = "${module.naming.monitor_metric_alert.name}-sql-dtu"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.sql_database_id]
  description         = "Alert when SQL Database DTU usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.sql_dtu_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
  
  tags = var.tags
}

# Cosmos DB Request Units Alert
resource "azurerm_monitor_metric_alert" "cosmos_db_ru" {
  count               = var.enable_alerts && var.cosmos_account_id != null ? 1 : 0
  name                = "${module.naming.monitor_metric_alert.name}-cosmos-ru"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.cosmos_account_id]
  description         = "Alert when Cosmos DB request units are high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "TotalRequestUnits"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.cosmos_ru_alert_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
  
  tags = var.tags
}

# Application Insights Availability Test
resource "azurerm_application_insights_web_test" "main" {
  count                   = var.enable_availability_test && var.app_service_url != null ? 1 : 0
  name                    = "${module.naming.application_insights_web_test.name}-availability"
  location                = azurerm_resource_group.monitoring.location
  resource_group_name     = azurerm_resource_group.monitoring.name
  application_insights_id = azurerm_application_insights.main.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 60
  enabled                 = true
  retry_enabled           = true
  geo_locations           = ["us-tx-sn1-azr", "us-il-ch1-azr", "us-ca-sjc-azr"]

  configuration = <<XML
<WebTest Name="${var.project_name}-availability-test" Id="${random_uuid.availability_test_id[0].result}" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="60" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialsUserName="" CredentialsPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="${random_uuid.availability_request_id[0].result}" Version="1.1" Url="${var.app_service_url}/health" ThinkTime="0" Timeout="60" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
  
  tags = var.tags
}

resource "random_uuid" "availability_test_id" {
  count = var.enable_availability_test && var.app_service_url != null ? 1 : 0
}

resource "random_uuid" "availability_request_id" {
  count = var.enable_availability_test && var.app_service_url != null ? 1 : 0
}

# Dashboard for monitoring
resource "azurerm_portal_dashboard" "main" {
  count                = var.create_dashboard ? 1 : 0
  name                 = "${module.naming.dashboard.name}-monitoring"
  resource_group_name  = azurerm_resource_group.monitoring.name
  location             = azurerm_resource_group.monitoring.location
  
  dashboard_properties = templatefile("${path.module}/dashboard.json", {
    app_service_name     = var.app_service_name
    app_service_id       = var.app_service_id
    sql_database_id      = var.sql_database_id
    cosmos_account_id    = var.cosmos_account_id
    application_insights_id = azurerm_application_insights.main.id
    subscription_id      = data.azurerm_client_config.current.subscription_id
    resource_group_name  = azurerm_resource_group.monitoring.name
  })
  
  tags = var.tags
}

data "azurerm_client_config" "current" {}