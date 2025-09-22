output "resource_group_name" {
  description = "Name of the networking resource group"
  value       = azurerm_resource_group.networking.name
}

output "resource_group_location" {
  description = "Location of the networking resource group"
  value       = azurerm_resource_group.networking.location
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "app_subnet_id" {
  description = "ID of the app service subnet"
  value       = azurerm_subnet.app.id
}

output "data_subnet_id" {
  description = "ID of the data subnet"
  value       = azurerm_subnet.data.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "private_dns_zone_sql_id" {
  description = "ID of the SQL private DNS zone"
  value       = azurerm_private_dns_zone.sql.id
}

output "private_dns_zone_cosmos_id" {
  description = "ID of the Cosmos DB private DNS zone"
  value       = azurerm_private_dns_zone.cosmos.id
}

output "private_dns_zone_keyvault_id" {
  description = "ID of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.keyvault.id
}

output "app_nsg_id" {
  description = "ID of the app service network security group"
  value       = azurerm_network_security_group.app.id
}

output "data_nsg_id" {
  description = "ID of the data network security group"
  value       = azurerm_network_security_group.data.id
}