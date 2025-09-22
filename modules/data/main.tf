# Data module for Azure SQL Database

# Random password for SQL Server admin (if not provided)
resource "random_password" "sql_admin" {
  count   = var.sql_admin_password == null ? 1 : 0
  length  = 24
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Azure SQL Server
resource "azurecaf_name" "sql_server" {
  name          = var.project_name
  resource_type = "azurerm_mssql_server"
  suffixes      = [var.environment_name]
}

resource "azurerm_mssql_server" "main" {
  name                         = azurecaf_name.sql_server.result
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password != null ? var.sql_admin_password : random_password.sql_admin[0].result
  
  # Security settings
  minimum_tls_version               = "1.2"
  public_network_access_enabled     = var.enable_private_endpoints ? false : true
  outbound_network_restriction_enabled = false
  
  # Azure AD authentication
  azuread_administrator {
    login_username              = var.managed_identity_name
    object_id                   = var.managed_identity_principal_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = false # Keep SQL auth for initial setup
  }

  tags = var.tags
}

# Azure SQL Database
resource "azurecaf_name" "sql_database" {
  name          = var.project_name
  resource_type = "azurerm_mssql_database"
  suffixes      = [var.environment_name]
}

resource "azurerm_mssql_database" "main" {
  name           = azurecaf_name.sql_database.result
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = var.database_max_size_gb
  read_scale     = false
  sku_name       = var.database_sku_name
  zone_redundant = var.zone_redundant
  
  # Threat detection
  threat_detection_policy {
    state                      = "Enabled"
    email_account_admins       = "Enabled"
    email_addresses            = var.admin_emails
    retention_days             = 30
    storage_endpoint           = var.security_storage_endpoint
    storage_account_access_key = var.security_storage_access_key
  }

  tags = var.tags
}

# SQL Server Firewall Rules (only if private endpoints are disabled)
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.enable_private_endpoints ? 0 : 1
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "allowed_ips" {
  count            = var.enable_private_endpoints ? 0 : length(var.allowed_ip_ranges)
  name             = "AllowedIP-${count.index}"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = split("/", var.allowed_ip_ranges[count.index])[0]
  end_ip_address   = split("/", var.allowed_ip_ranges[count.index])[0]
}

# Advanced Data Security settings
resource "azurerm_mssql_server_security_alert_policy" "main" {
  resource_group_name        = var.resource_group_name
  server_name                = azurerm_mssql_server.main.name
  state                      = "Enabled"
  storage_endpoint           = var.security_storage_endpoint
  storage_account_access_key = var.security_storage_access_key
  disabled_alerts            = []
  retention_days             = 30
  email_account_admins       = true
  email_addresses            = var.admin_emails
}

resource "azurerm_mssql_server_vulnerability_assessment" "main" {
  count                           = var.security_storage_endpoint != "" ? 1 : 0
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.main.id
  storage_container_path          = "${var.security_storage_endpoint}vulnerability-assessment/"
  storage_account_access_key      = var.security_storage_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.admin_emails
  }
}

# Diagnostic settings for monitoring
resource "azurerm_monitor_diagnostic_setting" "sql_server" {
  name                       = "sql-server-diagnostics"
  target_resource_id         = azurerm_mssql_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DevOpsOperationsAudit"
  }

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "sql_database" {
  name                       = "sql-database-diagnostics"
  target_resource_id         = azurerm_mssql_database.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "AutomaticTuning"
  }

  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }

  enabled_log {
    category = "QueryStoreWaitStatistics"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Timeouts"
  }

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "Deadlocks"
  }

  metric {
    category = "AllMetrics"
  }
}