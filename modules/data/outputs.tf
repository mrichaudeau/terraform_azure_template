output "resource_group_name" {
  description = "Name of the data resource group"
  value       = azurerm_resource_group.data.name
}

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.main.id
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "sql_connection_string" {
  description = "Connection string for SQL Database"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

output "sql_admin_password" {
  description = "SQL Server admin password"
  value       = random_password.sql_admin_password.result
  sensitive   = true
}

output "cosmos_account_id" {
  description = "ID of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmos_account_name" {
  description = "Name of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmos_endpoint" {
  description = "Endpoint for the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_primary_key" {
  description = "Primary key for the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmos_connection_strings" {
  description = "Connection strings for the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.main.connection_strings
  sensitive   = true
}

output "cosmos_database_name" {
  description = "Name of the Cosmos Database"
  value       = azurerm_cosmosdb_sql_database.main.name
}

output "cosmos_container_name" {
  description = "Name of the Cosmos Container"
  value       = azurerm_cosmosdb_sql_container.fastapi_data.name
}