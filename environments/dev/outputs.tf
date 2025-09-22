# Development Environment Outputs

output "app_service_url" {
  description = "URL of the deployed FastAPI application"
  value       = module.compute.app_service_url
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = module.compute.app_service_name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = module.data.sql_server_fqdn
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = module.data.sql_database_name
}

output "cosmos_endpoint" {
  description = "Cosmos DB endpoint"
  value       = module.data.cosmos_endpoint
}

output "cosmos_database_name" {
  description = "Cosmos DB database name"
  value       = module.data.cosmos_database_name
}

output "cosmos_container_name" {
  description = "Cosmos DB container name"
  value       = module.data.cosmos_container_name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.security.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
}

output "application_insights_name" {
  description = "Name of Application Insights"
  value       = module.monitoring.application_insights_name
}

output "application_insights_app_id" {
  description = "App ID for Application Insights"
  value       = module.monitoring.application_insights_app_id
}

output "resource_group_names" {
  description = "Names of all created resource groups"
  value = {
    networking = module.networking.resource_group_name
    security   = module.security.resource_group_name
    data       = module.data.resource_group_name
    compute    = module.compute.resource_group_name
    monitoring = module.monitoring.resource_group_name
  }
}

output "managed_identity_client_id" {
  description = "Client ID of the App Service managed identity"
  value       = module.security.app_service_identity_client_id
}

# Sensitive outputs for reference
output "sql_admin_password" {
  description = "SQL Server admin password"
  value       = module.data.sql_admin_password
  sensitive   = true
}

output "cosmos_primary_key" {
  description = "Cosmos DB primary key"
  value       = module.data.cosmos_primary_key
  sensitive   = true
}