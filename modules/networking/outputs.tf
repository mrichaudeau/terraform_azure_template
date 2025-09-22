# Outputs for the networking module

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "webapp_subnet_id" {
  description = "ID of the web app subnet"
  value       = azurerm_subnet.webapp.id
}

output "private_endpoints_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "sql_private_endpoint_ip" {
  description = "Private IP address of the SQL private endpoint"
  value       = var.enable_private_endpoints && length(azurerm_private_endpoint.sql) > 0 ? azurerm_private_endpoint.sql[0].private_service_connection[0].private_ip_address : null
}

output "keyvault_private_endpoint_ip" {
  description = "Private IP address of the Key Vault private endpoint"
  value       = var.enable_private_endpoints && length(azurerm_private_endpoint.keyvault) > 0 ? azurerm_private_endpoint.keyvault[0].private_service_connection[0].private_ip_address : null
}

output "private_dns_zone_ids" {
  description = "IDs of the private DNS zones"
  value = var.enable_private_endpoints ? {
    sql      = azurerm_private_dns_zone.sql[0].id
    keyvault = azurerm_private_dns_zone.keyvault[0].id
  } : {}
}