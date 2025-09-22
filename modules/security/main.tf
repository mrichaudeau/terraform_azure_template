# Security module for Key Vault and Managed Identity

# Get current client configuration for Key Vault access
data "azurerm_client_config" "current" {}

# User Assigned Managed Identity (required by AZD)
resource "azurecaf_name" "user_assigned_identity" {
  name          = var.project_name
  resource_type = "azurerm_user_assigned_identity"
  suffixes      = [var.environment_name]
}

resource "azurerm_user_assigned_identity" "main" {
  name                = azurecaf_name.user_assigned_identity.result
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Key Vault for storing secrets
resource "azurecaf_name" "key_vault" {
  name          = var.project_name
  resource_type = "azurerm_key_vault"
  suffixes      = [var.environment_name]
}

resource "azurerm_key_vault" "main" {
  name                       = azurecaf_name.key_vault.result
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = var.soft_delete_retention_days

  # Enable RBAC for access management (more secure than access policies)
  rbac_authorization_enabled = true
  
  # Security settings
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  purge_protection_enabled        = false # Set to true in production

  # Network access rules
  network_acls {
    bypass                     = "AzureServices"
    default_action             = var.enable_private_endpoints ? "Deny" : "Allow"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = []
  }

  tags = var.tags
}

# Key Vault access policy for the managed identity
resource "azurerm_role_assignment" "managed_identity_key_vault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Key Vault access policy for the current user/service principal (for deployment)
resource "azurerm_role_assignment" "current_user_key_vault_administrator" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Store SQL connection string in Key Vault
resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "sql-connection-string"
  value        = var.sql_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.current_user_key_vault_administrator
  ]

  tags = var.tags
}

# Store SQL admin password in Key Vault (if provided)
resource "azurerm_key_vault_secret" "sql_admin_password" {
  count        = var.sql_admin_password != null ? 1 : 0
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.current_user_key_vault_administrator
  ]

  tags = var.tags
}