# Production Environment Configuration for FastAPI with SQL and NoSQL
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    # Backend configuration should be provided via backend config file or CLI
    # Example backend config for production:
    # resource_group_name  = "rg-terraform-state-prod"
    # storage_account_name = "stterraformstateprod<suffix>"
    # container_name       = "tfstate"
    # key                  = "prod/fastapi-app.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false  # Keep soft delete for production
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true  # Prevent accidental deletion
    }
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Local variables for production environment
locals {
  environment = "prod"
  project_name = var.project_name
  location = var.location
  
  common_tags = {
    Environment   = local.environment
    Project       = local.project_name
    Owner         = var.owner
    CostCenter    = var.cost_center
    BusinessUnit  = var.business_unit
    Criticality   = "High"
    DataClass     = "Confidential"
    ManagedBy     = "Terraform"
    LastModified  = timestamp()
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"
  
  project_name        = local.project_name
  environment         = local.environment
  location            = local.location
  vnet_address_space  = var.vnet_address_space
  subnet_cidrs        = var.subnet_cidrs
  tags               = local.common_tags
}

# Security Module
module "security" {
  source = "../../modules/security"
  
  project_name                  = local.project_name
  environment                   = local.environment
  location                      = local.location
  data_subnet_id                = module.networking.data_subnet_id
  keyvault_private_dns_zone_id  = module.networking.private_dns_zone_keyvault_id
  tags                          = local.common_tags

  depends_on = [module.networking]
}

# Data Module
module "data" {
  source = "../../modules/data"
  
  project_name                 = local.project_name
  environment                  = local.environment
  location                     = local.location
  data_subnet_id               = module.networking.data_subnet_id
  sql_private_dns_zone_id      = module.networking.private_dns_zone_sql_id
  cosmos_private_dns_zone_id   = module.networking.private_dns_zone_cosmos_id
  
  # Production specific database settings
  sql_database_sku             = var.sql_database_sku
  sql_admin_username           = var.sql_admin_username
  sql_database_name            = var.sql_database_name
  
  cosmos_database_name         = var.cosmos_database_name
  cosmos_consistency_level     = var.cosmos_consistency_level
  cosmos_max_throughput        = var.cosmos_max_throughput
  cosmos_container_max_throughput = var.cosmos_container_max_throughput
  cosmos_secondary_region      = var.cosmos_secondary_region
  
  # Azure AD admin settings
  azuread_admin_login          = var.azuread_admin_login
  azuread_admin_object_id      = var.azuread_admin_object_id
  azuread_admin_tenant_id      = data.azurerm_client_config.current.tenant_id
  
  tags = local.common_tags

  depends_on = [module.networking]
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"
  
  project_name                 = local.project_name
  environment                  = local.environment
  location                     = local.location
  
  app_service_id               = module.compute.app_service_id
  app_service_name             = module.compute.app_service_name
  app_service_url              = module.compute.app_service_url
  sql_database_id              = module.data.sql_database_id
  cosmos_account_id            = module.data.cosmos_account_id
  
  # Production monitoring settings
  log_analytics_retention_days = 365  # Longer retention for production
  enable_alerts               = var.enable_alerts
  enable_availability_test    = var.enable_availability_test
  create_dashboard            = var.create_dashboard
  
  # Alert configurations for production (most sensitive)
  cpu_alert_threshold         = var.cpu_alert_threshold
  memory_alert_threshold      = var.memory_alert_threshold
  response_time_alert_threshold = var.response_time_alert_threshold
  sql_dtu_alert_threshold     = var.sql_dtu_alert_threshold
  cosmos_ru_alert_threshold   = var.cosmos_ru_alert_threshold
  
  alert_email_addresses       = var.alert_email_addresses
  alert_sms_numbers          = var.alert_sms_numbers
  
  tags = local.common_tags
  
  depends_on = [module.compute, module.data]
}

# Compute Module
module "compute" {
  source = "../../modules/compute"
  
  project_name                          = local.project_name
  environment                           = local.environment
  location                              = local.location
  
  app_subnet_id                         = module.networking.app_subnet_id
  managed_identity_id                   = module.security.app_service_identity_id
  managed_identity_client_id            = module.security.app_service_identity_client_id
  
  # Key Vault integration
  key_vault_name                        = module.security.key_vault_name
  sql_connection_string_secret_name     = module.security.sql_connection_string_secret_name
  cosmos_connection_string_secret_name  = module.security.cosmos_connection_string_secret_name
  cosmos_primary_key_secret_name        = module.security.cosmos_primary_key_secret_name
  
  # Database configuration
  cosmos_endpoint                       = module.data.cosmos_endpoint
  cosmos_database_name                  = module.data.cosmos_database_name
  cosmos_container_name                 = module.data.cosmos_container_name
  sql_database_name                     = module.data.sql_database_name
  
  # Application Insights
  application_insights_instrumentation_key = module.monitoring.application_insights_instrumentation_key
  application_insights_connection_string   = module.monitoring.application_insights_connection_string
  
  # Production specific settings
  app_service_sku                      = var.app_service_sku
  public_network_access_enabled        = var.public_network_access_enabled
  cors_allowed_origins                 = var.cors_allowed_origins
  custom_domain                        = var.custom_domain
  backup_storage_account_url           = var.backup_storage_account_url
  autoscale_min_instances              = var.autoscale_min_instances
  autoscale_max_instances              = var.autoscale_max_instances
  
  tags = local.common_tags
  
  depends_on = [module.networking, module.security, module.data, module.monitoring]
}

# Update Key Vault secrets with actual connection strings
resource "azurerm_key_vault_secret" "sql_connection_string_update" {
  name         = module.security.sql_connection_string_secret_name
  value        = "${module.data.sql_connection_string};Password=${module.data.sql_admin_password}"
  key_vault_id = module.security.key_vault_id
  
  depends_on = [module.security, module.data]
}

resource "azurerm_key_vault_secret" "cosmos_connection_string_update" {
  name         = module.security.cosmos_connection_string_secret_name
  value        = module.data.cosmos_connection_strings[0]
  key_vault_id = module.security.key_vault_id
  
  depends_on = [module.security, module.data]
}

resource "azurerm_key_vault_secret" "cosmos_primary_key_update" {
  name         = module.security.cosmos_primary_key_secret_name
  value        = module.data.cosmos_primary_key
  key_vault_id = module.security.key_vault_id
  
  depends_on = [module.security, module.data]
}