variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "app_subnet_id" {
  description = "ID of the app service subnet"
  type        = string
}

variable "managed_identity_id" {
  description = "ID of the managed identity for the app service"
  type        = string
}

variable "managed_identity_client_id" {
  description = "Client ID of the managed identity"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "sql_connection_string_secret_name" {
  description = "Name of the SQL connection string secret in Key Vault"
  type        = string
}

variable "cosmos_connection_string_secret_name" {
  description = "Name of the Cosmos DB connection string secret in Key Vault"
  type        = string
}

variable "cosmos_primary_key_secret_name" {
  description = "Name of the Cosmos DB primary key secret in Key Vault"
  type        = string
}

variable "cosmos_endpoint" {
  description = "Cosmos DB endpoint"
  type        = string
}

variable "cosmos_database_name" {
  description = "Cosmos DB database name"
  type        = string
}

variable "cosmos_container_name" {
  description = "Cosmos DB container name"
  type        = string
}

variable "sql_database_name" {
  description = "SQL database name"
  type        = string
}

variable "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  type        = string
}

variable "application_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "B1"
  validation {
    condition = contains([
      "F1", "D1", "B1", "B2", "B3", "S1", "S2", "S3", "P1v2", "P2v2", "P3v2", "P1v3", "P2v3", "P3v3"
    ], var.app_service_sku)
    error_message = "App Service SKU must be a valid Azure App Service SKU."
  }
}

variable "public_network_access_enabled" {
  description = "Enable public network access for App Service"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "custom_domain" {
  description = "Custom domain for the App Service"
  type        = string
  default     = null
}

variable "backup_storage_account_url" {
  description = "Storage account URL for backups"
  type        = string
  default     = null
}

variable "autoscale_min_instances" {
  description = "Minimum number of instances for autoscaling"
  type        = number
  default     = 1
}

variable "autoscale_max_instances" {
  description = "Maximum number of instances for autoscaling"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}