output "resource_group_name" {
  description = "Name of the compute resource group"
  value       = azurerm_resource_group.compute.name
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.main.id
}

output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.main.name
}

output "app_service_id" {
  description = "ID of the App Service"
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "app_service_custom_domain_verification_id" {
  description = "Custom domain verification ID"
  value       = azurerm_linux_web_app.main.custom_domain_verification_id
}

output "app_service_outbound_ip_addresses" {
  description = "Outbound IP addresses of the App Service"
  value       = azurerm_linux_web_app.main.outbound_ip_addresses
}

output "app_service_possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses of the App Service"
  value       = azurerm_linux_web_app.main.possible_outbound_ip_addresses
}

output "app_service_url" {
  description = "URL of the deployed FastAPI application"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}