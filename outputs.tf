# Output values for the Python SQL Web App deployment
# Required by AZD and useful for integration with other systems

# Required by AZD
output "RESOURCE_GROUP_ID" {
  description = "The ID of the resource group (required by AZD)"
  value       = azurerm_resource_group.main.id
}

# Application endpoints and connection information
output "WEB_APP_URL" {
  description = "The URL of the deployed web application"
  value       = "https://${module.compute.app_service_default_hostname}"
}

output "WEB_APP_NAME" {
  description = "The name of the App Service"
  value       = module.compute.app_service_name
}

# Database connection information
output "SQL_SERVER_FQDN" {
  description = "The fully qualified domain name of the SQL server"
  value       = module.data.sql_server_fqdn
  sensitive   = true
}

output "SQL_DATABASE_NAME" {
  description = "The name of the SQL database"
  value       = module.data.sql_database_name
}

# Security and identity information  
output "MANAGED_IDENTITY_CLIENT_ID" {
  description = "The client ID of the user-assigned managed identity"
  value       = module.security.user_assigned_identity_client_id
}

output "MANAGED_IDENTITY_PRINCIPAL_ID" {
  description = "The principal ID of the user-assigned managed identity"
  value       = module.security.user_assigned_identity_principal_id
}

output "KEY_VAULT_NAME" {
  description = "The name of the Key Vault"
  value       = module.security.key_vault_name
}

output "KEY_VAULT_URI" {
  description = "The URI of the Key Vault"
  value       = module.security.key_vault_uri
  sensitive   = true
}

# Network information
output "VNET_ID" {
  description = "The ID of the virtual network"
  value       = module.networking.vnet_id
}

output "PRIVATE_ENDPOINT_IPS" {
  description = "Private IP addresses of the private endpoints"
  value = {
    sql_database = module.networking.sql_private_endpoint_ip
    key_vault    = module.networking.keyvault_private_endpoint_ip
  }
  sensitive = true
}

# Monitoring information
output "APPLICATION_INSIGHTS_CONNECTION_STRING" {
  description = "Application Insights connection string"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

output "APPLICATION_INSIGHTS_INSTRUMENTATION_KEY" {
  description = "Application Insights instrumentation key"
  value       = module.monitoring.application_insights_instrumentation_key
  sensitive   = true
}

output "LOG_ANALYTICS_WORKSPACE_ID" {
  description = "Log Analytics workspace ID"
  value       = module.monitoring.log_analytics_workspace_id
}

# Environment information for debugging
output "ENVIRONMENT_NAME" {
  description = "The environment name"
  value       = var.environment_name
}

output "AZURE_LOCATION" {
  description = "The Azure location where resources are deployed"
  value       = var.location
}

# Resource naming information
output "RESOURCE_NAMES" {
  description = "Names of all major resources created"
  value = {
    resource_group  = azurerm_resource_group.main.name
    app_service     = module.compute.app_service_name
    app_service_plan = module.compute.app_service_plan_name
    sql_server      = module.data.sql_server_name
    sql_database    = module.data.sql_database_name
    key_vault       = module.security.key_vault_name
    managed_identity = module.security.user_assigned_identity_name
    vnet            = module.networking.vnet_name
    application_insights = module.monitoring.application_insights_name
    log_analytics   = module.monitoring.log_analytics_workspace_name
  }
}