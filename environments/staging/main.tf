# Staging environment configuration
# Terraform configuration for the staging environment

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

  # Staging-specific configuration
  project_name = "python-sql-webapp"
  
  # Mid-tier settings for staging
  app_service_sku = {
    tier = "Standard"
    size = "S1"
  }
  
  sql_database_sku = {
    name     = "Standard"
    tier     = "Standard"
    capacity = 20
  }
  
  # Security settings (production-like)
  enable_private_endpoints = true
  enable_managed_identity = true
  
  # Network settings
  vnet_address_space = ["10.1.0.0/16"]
  allowed_ip_ranges = [] # Add your IP ranges for staging access
  
  # Database settings
  sql_admin_login = "sqladmin"
  sql_admin_password = var.sqlAdminPassword
  
  # Enhanced monitoring settings for staging
  key_vault_soft_delete_retention = 30

  # Tagging
  owner        = "QA Team"
  cost_center  = "Testing"
  business_unit = "Engineering"
  criticality  = "Medium"
  data_class   = "Internal"
}