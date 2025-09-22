# Compute module for Azure App Service (Python web app)

# Get current client configuration for tenant info
data "azurerm_client_config" "current" {}

# App Service Plan
resource "azurecaf_name" "app_service_plan" {
  name          = var.project_name
  resource_type = "azurerm_app_service_plan"
  suffixes      = [var.environment_name]
}

resource "azurerm_service_plan" "main" {
  name                = azurecaf_name.app_service_plan.result
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "${var.app_service_sku.tier}_${var.app_service_sku.size}"

  tags = var.tags
}

# App Service (Web App)
resource "azurecaf_name" "app_service" {
  name          = var.project_name
  resource_type = "azurerm_app_service"
  suffixes      = [var.environment_name]
}

resource "azurerm_linux_web_app" "main" {
  name                = azurecaf_name.app_service.result
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  # Required AZD tag for service identification
  tags = merge(var.tags, {
    "azd-service-name" = var.azd_service_name
  })

  # Enable system-assigned managed identity if user-assigned is not provided
  identity {
    type = var.user_assigned_identity_id != null ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.user_assigned_identity_id != null ? [var.user_assigned_identity_id] : null
  }

  # Site configuration
  site_config {
    application_stack {
      python_version = var.python_version
    }

    # Security settings
    always_on                         = var.app_service_sku.tier != "Free" && var.app_service_sku.tier != "Shared"
    ftps_state                       = "FtpsOnly"
    http2_enabled                    = true
    minimum_tls_version              = "1.2"
    scm_minimum_tls_version          = "1.2"
    use_32_bit_worker                = false
    websockets_enabled               = false
    remote_debugging_enabled         = false
    
    # Health check
    health_check_path                = "/health"
    health_check_eviction_time_in_min = 2

    # CORS settings (adjust as needed)
    cors {
      allowed_origins     = var.allowed_origins
      support_credentials = false
    }
  }

  # HTTPS only
  https_only = true

  # Application settings
  app_settings = merge({
    # Python specific settings
    "SCM_DO_BUILD_DURING_DEPLOYMENT"       = "true"
    "ENABLE_ORYX_BUILD"                    = "true"
    "BUILD_FLAGS"                          = "UseExpressBuild"
    
    # Application Insights
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    
    # Database connection (using Key Vault reference)
    "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=${var.key_vault_uri}secrets/${var.sql_connection_secret_name})"
    
    # Managed Identity
    "AZURE_CLIENT_ID" = var.user_assigned_identity_client_id != null ? var.user_assigned_identity_client_id : ""
    
    # Custom application settings
    "ENVIRONMENT" = var.environment_name
    "PROJECT_NAME" = var.project_name
    
  }, var.additional_app_settings)

  # Connection strings (for legacy compatibility if needed)
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "@Microsoft.KeyVault(SecretUri=${var.key_vault_uri}secrets/${var.sql_connection_secret_name})"
  }

  # Virtual Network integration
  virtual_network_subnet_id = var.subnet_id

  # Logging configuration
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    
    application_logs {
      file_system_level = "Information"
    }
    
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  # Auto-heal rules for reliability (configured in site_config)
  
  dynamic "auto_heal_setting" {
    for_each = var.enable_auto_heal ? [1] : []
    content {
      action {
        action_type = "Recycle"
      }
      
      trigger {
        requests {
          count    = 100
          interval = "00:05:00"
        }
        
        status_code {
          count             = 10
          interval          = "00:05:00"
          status_code_range = "500-599"
        }
        
        slow_request {
          count      = 5
          interval   = "00:05:00"
          time_taken = "00:01:00"
        }
      }
    }
  }
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "app_service" {
  name                       = "app-service-diagnostics"
  target_resource_id         = azurerm_linux_web_app.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  
  enabled_log {
    category = "AppServiceAppLogs"
  }
  
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  
  enabled_log {
    category = "AppServiceIPSecAuditLogs"
  }
  
  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

# Role assignment for SQL Database access via managed identity
resource "azurerm_role_assignment" "sql_db_contributor" {
  count                = var.sql_server_id != null ? 1 : 0
  scope                = var.sql_server_id
  role_definition_name = "SQL DB Contributor"
  principal_id         = var.user_assigned_identity_principal_id != null ? var.user_assigned_identity_principal_id : azurerm_linux_web_app.main.identity[0].principal_id
}

# Custom domain and SSL (optional)
resource "azurerm_app_service_custom_hostname_binding" "main" {
  count               = var.custom_hostname != null ? 1 : 0
  hostname            = var.custom_hostname
  app_service_name    = azurerm_linux_web_app.main.name
  resource_group_name = var.resource_group_name
}

# Deployment slot for blue-green deployments (production only)
resource "azurerm_linux_web_app_slot" "staging" {
  count          = var.enable_staging_slot ? 1 : 0
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id

  site_config {
    application_stack {
      python_version = var.python_version
    }
    always_on           = azurerm_linux_web_app.main.site_config[0].always_on
    ftps_state         = "FtpsOnly"
    http2_enabled      = true
    minimum_tls_version = "1.2"
  }

  app_settings = azurerm_linux_web_app.main.app_settings

  tags = var.tags
}