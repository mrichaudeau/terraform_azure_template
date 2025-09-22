# Outputs for the security module

output "user_assigned_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.id
}

output "user_assigned_identity_name" {
  description = "Name of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.name
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.client_id
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.principal_id
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

output "sql_connection_string_secret_id" {
  description = "ID of the SQL connection string secret in Key Vault"
  value       = azurerm_key_vault_secret.sql_connection_string.id
}

output "sql_connection_string_secret_name" {
  description = "Name of the SQL connection string secret in Key Vault"
  value       = azurerm_key_vault_secret.sql_connection_string.name
}