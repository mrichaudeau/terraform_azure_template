output "resource_group_name" {
  description = "Name of the security resource group"
  value       = azurerm_resource_group.security.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "app_service_identity_id" {
  description = "ID of the App Service managed identity"
  value       = azurerm_user_assigned_identity.app_service.id
}

output "app_service_identity_principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = azurerm_user_assigned_identity.app_service.principal_id
}

output "app_service_identity_client_id" {
  description = "Client ID of the App Service managed identity"
  value       = azurerm_user_assigned_identity.app_service.client_id
}

output "sql_connection_string_secret_name" {
  description = "Name of the SQL connection string secret in Key Vault"
  value       = azurerm_key_vault_secret.sql_connection_string.name
}

output "cosmos_connection_string_secret_name" {
  description = "Name of the Cosmos DB connection string secret in Key Vault"
  value       = azurerm_key_vault_secret.cosmos_connection_string.name
}

output "cosmos_primary_key_secret_name" {
  description = "Name of the Cosmos DB primary key secret in Key Vault"
  value       = azurerm_key_vault_secret.cosmos_primary_key.name
}