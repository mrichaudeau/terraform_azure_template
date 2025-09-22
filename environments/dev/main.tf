# Development environment configuration
# Terraform configuration for the development environment

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
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
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

  # Development-specific configuration
  project_name = "python-sql-webapp"
  
  # Cost-optimized settings for dev
  app_service_sku = {
    tier = "Basic"
    size = "B1"
  }
  
  sql_database_sku = {
    name     = "Basic"
    tier     = "Basic"
    capacity = 5
  }
  
  # Security settings
  enable_private_endpoints = false # Disabled in dev for easier access
  enable_managed_identity = true
  
  # Network settings
  vnet_address_space = ["10.0.0.0/16"]
  allowed_ip_ranges = [] # Add your IP ranges for dev access
  
  # Database settings
  sql_admin_login = "sqladmin"
  sql_admin_password = var.sqlAdminPassword
  
  # Monitoring settings (basic for dev)
  key_vault_soft_delete_retention = 7

  # Tagging
  owner        = "Development Team"
  cost_center  = "Development"
  business_unit = "Engineering"
  criticality  = "Low"
  data_class   = "Internal"
}