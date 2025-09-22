# Variables for the compute module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# App Service Plan configuration
variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type = object({
    tier = string
    size = string
  })
  default = {
    tier = "Standard"
    size = "S1"
  }
}

# App Service configuration
variable "azd_service_name" {
  description = "Service name for AZD tagging (required)"
  type        = string
  default     = "python-sql-webapp"
}

variable "python_version" {
  description = "Python version for the web app"
  type        = string
  default     = "3.11"
}

variable "allowed_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

# Managed Identity configuration
variable "user_assigned_identity_id" {
  description = "ID of the user-assigned managed identity"
  type        = string
  default     = null
}

variable "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned managed identity"
  type        = string
  default     = null
}

variable "user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity"
  type        = string
  default     = null
}

# Network configuration
variable "subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

# External service configuration
variable "application_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "key_vault_uri" {
  description = "URI of the Key Vault"
  type        = string
}

variable "sql_connection_secret_name" {
  description = "Name of the SQL connection string secret in Key Vault"
  type        = string
  default     = "sql-connection-string"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
}

variable "sql_server_id" {
  description = "ID of the SQL server for RBAC assignment"
  type        = string
  default     = null
}

# Additional settings
variable "additional_app_settings" {
  description = "Additional app settings for the web app"
  type        = map(string)
  default     = {}
}

variable "custom_hostname" {
  description = "Custom hostname for the web app"
  type        = string
  default     = null
}

variable "enable_staging_slot" {
  description = "Enable staging deployment slot"
  type        = bool
  default     = false
}

variable "enable_auto_heal" {
  description = "Enable auto-heal for the web app"
  type        = bool
  default     = true
}