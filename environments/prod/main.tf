# Production environment configuration
# Terraform configuration for the production environment

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.28"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Backend will be configured by azd
  backend "azurerm" {}
}

# Provider configuration
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false # Keep soft delete protection in prod
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true # Prevent accidental deletion in prod
    }
  }
}

# Use the main module
module "python_sql_webapp" {
  source = "../../"

  # Required AZD parameters
  environment_name    = var.environmentName
  location           = var.location
  resource_group_name = var.resourceGroupName

  # Production-specific configuration
  project_name = "python-sql-webapp"
  
  # Production-grade settings
  app_service_sku = {
    tier = "PremiumV3"
    size = "P1V3"
  }
  
  sql_database_sku = {
    name     = "Standard"
    tier     = "Standard"
    capacity = 100
  }
  
  # Full security settings for production
  enable_private_endpoints = true
  enable_managed_identity = true
  
  # Network settings
  vnet_address_space = ["10.2.0.0/16"]
  allowed_ip_ranges = [] # No direct IP access in production
  
  # Database settings
  sql_admin_login = "sqladmin"
  sql_admin_password = var.sqlAdminPassword
  
  # Enhanced security for production
  key_vault_soft_delete_retention = 90

  # Production tagging
  owner        = "Operations Team"
  cost_center  = "Production"
  business_unit = "Business Critical"
  criticality  = "High"
  data_class   = "Confidential"
}