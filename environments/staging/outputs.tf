# Staging environment outputs
# These outputs are required by AZD and useful for operations

# Required by AZD
output "RESOURCE_GROUP_ID" {
  description = "Resource group ID (required by AZD)"
  value       = module.python_sql_webapp.RESOURCE_GROUP_ID
}

# Application information
output "WEB_APP_URL" {
  description = "URL of the deployed web application"
  value       = module.python_sql_webapp.WEB_APP_URL
}

output "WEB_APP_NAME" {
  description = "Name of the App Service"
  value       = module.python_sql_webapp.WEB_APP_NAME
}

# Database information
output "SQL_SERVER_FQDN" {
  description = "Fully qualified domain name of the SQL server"
  value       = module.python_sql_webapp.SQL_SERVER_FQDN
  sensitive   = true
}

output "SQL_DATABASE_NAME" {
  description = "Name of the SQL database"
  value       = module.python_sql_webapp.SQL_DATABASE_NAME
}

# Security information
output "MANAGED_IDENTITY_CLIENT_ID" {
  description = "Client ID of the managed identity"
  value       = module.python_sql_webapp.MANAGED_IDENTITY_CLIENT_ID
}

output "KEY_VAULT_NAME" {
  description = "Name of the Key Vault"
  value       = module.python_sql_webapp.KEY_VAULT_NAME
}

# Monitoring information
output "APPLICATION_INSIGHTS_CONNECTION_STRING" {
  description = "Application Insights connection string"
  value       = module.python_sql_webapp.APPLICATION_INSIGHTS_CONNECTION_STRING
  sensitive   = true
}