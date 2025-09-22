# Security Module - Key Vault, Managed Identities, and Private Endpoints
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Azure Naming Module
module "naming" {
  source = "Azure/naming/azurerm"
  suffix = [var.project_name, var.environment]
}

# Random suffix for Key Vault (must be globally unique)
resource "random_string" "keyvault_suffix" {
  length  = 4
  upper   = false
  special = false
}

# Resource Group for Security
resource "azurerm_resource_group" "security" {
  name     = "${module.naming.resource_group.name}-security"
  location = var.location
  tags     = var.tags
}

# User Assigned Managed Identity for App Service
resource "azurerm_user_assigned_identity" "app_service" {
  name                = "${module.naming.user_assigned_identity.name}-app"
  resource_group_name = azurerm_resource_group.security.name
  location            = azurerm_resource_group.security.location
  tags                = var.tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "${module.naming.key_vault.name}${random_string.keyvault_suffix.result}"
  location                    = azurerm_resource_group.security.location
  resource_group_name         = azurerm_resource_group.security.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  
  # Disable public network access - use private endpoint
  public_network_access_enabled = false
  
  tags = var.tags
}

# Key Vault Access Policy for Current User (for initial setup)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", 
    "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", 
    "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", 
    "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", 
    "Restore", "SetIssuers", "Update"
  ]
}

# Key Vault Access Policy for App Service Managed Identity
resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app_service.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "keyvault" {
  name                = "${module.naming.private_endpoint.name}-kv"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  subnet_id           = var.data_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${module.naming.private_endpoint.name}-kv-connection"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [var.keyvault_private_dns_zone_id]
  }
}

# Key Vault Secrets (placeholders - will be populated during deployment)
resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "sql-connection-string"
  value        = "placeholder-will-be-updated"
  key_vault_id = azurerm_key_vault.main.id
  
  depends_on = [azurerm_key_vault_access_policy.current_user]
  tags       = var.tags
}

resource "azurerm_key_vault_secret" "cosmos_connection_string" {
  name         = "cosmos-connection-string"
  value        = "placeholder-will-be-updated"
  key_vault_id = azurerm_key_vault.main.id
  
  depends_on = [azurerm_key_vault_access_policy.current_user]
  tags       = var.tags
}

resource "azurerm_key_vault_secret" "cosmos_primary_key" {
  name         = "cosmos-primary-key"
  value        = "placeholder-will-be-updated"
  key_vault_id = azurerm_key_vault.main.id
  
  depends_on = [azurerm_key_vault_access_policy.current_user]
  tags       = var.tags
}