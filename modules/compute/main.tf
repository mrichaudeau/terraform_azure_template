# Compute Module - App Service for FastAPI
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

# Random suffix for globally unique resources
resource "random_string" "app_suffix" {
  length  = 4
  upper   = false
  special = false
}

# Resource Group for Compute Services
resource "azurerm_resource_group" "compute" {
  name     = "${module.naming.resource_group.name}-compute"
  location = var.location
  tags     = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = module.naming.app_service_plan.name
  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_resource_group.compute.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  
  tags = var.tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "${module.naming.app_service.name}${random_string.app_suffix.result}"
  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id
  
  # Enable HTTPS only
  https_only = true
  
  # Disable public network access initially (can be enabled for testing)
  public_network_access_enabled = var.public_network_access_enabled
  
  tags = var.tags

  site_config {
    # Always on for production
    always_on = var.environment == "prod" ? true : false
    
    # Use managed identity for container registry access
    container_registry_use_managed_identity = true
    
    # Python runtime
    application_stack {
      python_version = "3.11"
    }
    
    # Health check
    health_check_path = "/health"
    
    # Enable detailed error messages for non-production
    detailed_error_logging_enabled = var.environment != "prod"
    
    # CORS settings
    cors {
      allowed_origins = var.cors_allowed_origins
      support_credentials = true
    }
  }

  # App settings for FastAPI application
  app_settings = {
    # Python specific settings
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD"               = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    
    # FastAPI settings
    "FASTAPI_ENV"                     = var.environment
    "DEBUG"                           = var.environment != "prod" ? "true" : "false"
    
    # Key Vault references for database connections
    "SQL_CONNECTION_STRING"           = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=${var.sql_connection_string_secret_name})"
    "COSMOS_CONNECTION_STRING"        = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=${var.cosmos_connection_string_secret_name})"
    "COSMOS_PRIMARY_KEY"              = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=${var.cosmos_primary_key_secret_name})"
    
    # Database configuration
    "COSMOS_ENDPOINT"                 = var.cosmos_endpoint
    "COSMOS_DATABASE_NAME"            = var.cosmos_database_name
    "COSMOS_CONTAINER_NAME"           = var.cosmos_container_name
    "SQL_DATABASE_NAME"               = var.sql_database_name
    
    # Application Insights
    "APPINSIGHTS_INSTRUMENTATIONKEY" = var.application_insights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_connection_string
    
    # Managed Identity Client ID
    "AZURE_CLIENT_ID"                 = var.managed_identity_client_id
  }

  # Assign managed identity
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  # Logs configuration
  logs {
    detailed_error_messages = var.environment != "prod"
    failed_request_tracing  = var.environment != "prod"
    
    http_logs {
      file_system {
        retention_in_days = var.environment == "prod" ? 30 : 7
        retention_in_mb   = 35
      }
    }
    
    application_logs {
      file_system_level = var.environment == "prod" ? "Warning" : "Information"
    }
  }

  # Backup configuration for production
  dynamic "backup" {
    for_each = var.environment == "prod" && var.backup_storage_account_url != null ? [1] : []
    content {
      name                = "${var.project_name}-backup"
      enabled             = true
      storage_account_url = var.backup_storage_account_url
      
      schedule {
        frequency_interval       = 1
        frequency_unit          = "Day"
        retention_period_days   = 30
        start_time             = "2023-01-01T02:00:00Z"
      }
    }
  }
}

# VNet Integration for App Service
resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.app_subnet_id
}

# Custom Domain and SSL Certificate (optional)
resource "azurerm_app_service_custom_hostname_binding" "main" {
  count               = var.custom_domain != null ? 1 : 0
  hostname            = var.custom_domain
  app_service_name    = azurerm_linux_web_app.main.name
  resource_group_name = azurerm_resource_group.compute.name
  
  depends_on = [azurerm_linux_web_app.main]
}

# Auto-scaling configuration for production
resource "azurerm_monitor_autoscale_setting" "main" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "${module.naming.monitor_autoscale_setting.name}-app"
  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_resource_group.compute.location
  target_resource_id  = azurerm_service_plan.main.id
  
  tags = var.tags

  profile {
    name = "default"

    capacity {
      default = var.autoscale_min_instances
      minimum = var.autoscale_min_instances
      maximum = var.autoscale_max_instances
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}