# Main Terraform configuration for Python SQL Web App
# This file orchestrates all modules to create a complete application infrastructure

# Provider configuration
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Resource Group (required by AZD with specific tag)
resource "azurecaf_name" "resource_group" {
  name          = var.project_name
  resource_type = "azurerm_resource_group"
  suffixes      = [var.environment_name]
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "rg-${var.environment_name}"
  location = var.location

  # Required AZD tag for resource group identification
  tags = merge(local.common_tags, {
    "azd-env-name" = var.environment_name
  })
}

# Create monitoring resources first (needed by other modules)
module "monitoring" {
  source = "./modules/monitoring"

  project_name                 = var.project_name
  environment_name             = var.environment_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.main.name
  tags                        = local.common_tags
  log_analytics_sku           = "PerGB2018"
  log_retention_days          = var.environment_name == "prod" ? 365 : 30
  app_insights_retention_days = var.environment_name == "prod" ? 365 : 90
  enable_alerts               = var.environment_name == "prod"
  alert_email_addresses       = [] # Add admin emails as needed
  app_service_id              = try(module.compute.app_service_id, "")
}

# Create security resources (Key Vault and Managed Identity)
module "security" {
  source = "./modules/security"

  project_name                = var.project_name
  environment_name            = var.environment_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  tags                       = local.common_tags
  enable_private_endpoints   = var.enable_private_endpoints
  allowed_ip_ranges          = var.allowed_ip_ranges
  soft_delete_retention_days = var.key_vault_soft_delete_retention
  sql_connection_string      = module.data.sql_connection_string
  sql_admin_password         = var.sql_admin_password
}

# Create data resources (SQL Server and Database)
module "data" {
  source = "./modules/data"

  project_name                     = var.project_name
  environment_name                 = var.environment_name
  location                         = var.location
  resource_group_name              = azurerm_resource_group.main.name
  tags                            = local.common_tags
  sql_admin_login                 = var.sql_admin_login
  sql_admin_password              = var.sql_admin_password
  enable_private_endpoints        = var.enable_private_endpoints
  allowed_ip_ranges               = var.allowed_ip_ranges
  database_max_size_gb            = var.environment_name == "prod" ? 100 : var.sql_database_sku.capacity
  database_sku_name               = var.sql_database_sku.name
  zone_redundant                  = var.environment_name == "prod"
  managed_identity_name           = module.security.user_assigned_identity_name
  managed_identity_principal_id   = module.security.user_assigned_identity_principal_id
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  log_analytics_workspace_id      = module.monitoring.log_analytics_workspace_id
}

# Create networking resources (VNet, subnets, private endpoints)
module "networking" {
  source = "./modules/networking"

  project_name              = var.project_name
  environment_name          = var.environment_name
  location                  = var.location
  resource_group_name       = azurerm_resource_group.main.name
  tags                     = local.common_tags
  vnet_address_space       = var.vnet_address_space
  subnet_cidrs             = local.subnet_cidrs
  enable_private_endpoints = var.enable_private_endpoints
  sql_server_id           = module.data.sql_server_id
  sql_server_name         = module.data.sql_server_name
  key_vault_id            = module.security.key_vault_id
  key_vault_name          = module.security.key_vault_name
}

# Create compute resources (App Service)
module "compute" {
  source = "./modules/compute"

  project_name                           = var.project_name
  environment_name                       = var.environment_name
  location                               = var.location
  resource_group_name                    = azurerm_resource_group.main.name
  tags                                  = local.common_tags
  app_service_sku                       = var.app_service_sku
  azd_service_name                      = var.project_name
  python_version                        = "3.11"
  user_assigned_identity_id             = module.security.user_assigned_identity_id
  user_assigned_identity_client_id      = module.security.user_assigned_identity_client_id
  user_assigned_identity_principal_id   = module.security.user_assigned_identity_principal_id
  subnet_id                             = var.enable_private_endpoints ? module.networking.webapp_subnet_id : null
  application_insights_connection_string = module.monitoring.application_insights_connection_string
  key_vault_uri                         = module.security.key_vault_uri
  sql_connection_secret_name            = module.security.sql_connection_string_secret_name
  log_analytics_workspace_id            = module.monitoring.log_analytics_workspace_id
  sql_server_id                         = module.data.sql_server_id
  enable_staging_slot                   = var.environment_name == "prod"
  enable_auto_heal                      = true
}

