# Outputs for the data module

output "sql_server_id" {
  description = "ID of the SQL server"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_name" {
  description = "Name of the SQL server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "ID of the SQL database"
  value       = azurerm_mssql_database.main.id
}

output "sql_database_name" {
  description = "Name of the SQL database"
  value       = azurerm_mssql_database.main.name
}

output "sql_connection_string" {
  description = "SQL Server connection string"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Authentication=Active Directory Default;Encrypt=true;TrustServerCertificate=false"
  sensitive   = true
}

output "sql_admin_password" {
  description = "Generated SQL admin password (if auto-generated)"
  value       = var.sql_admin_password != null ? var.sql_admin_password : random_password.sql_admin[0].result
  sensitive   = true
}