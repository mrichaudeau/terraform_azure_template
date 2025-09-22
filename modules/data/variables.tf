# Variables for the data module

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

# SQL Server configuration
variable "sql_admin_login" {
  description = "Administrator login for the SQL server"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "Administrator password for the SQL server"
  type        = string
  sensitive   = true
  default     = null
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for SQL Database"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access SQL Database"
  type        = list(string)
  default     = []
}

# Database configuration
variable "database_max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 2
}

variable "database_sku_name" {
  description = "SKU name for the database"
  type        = string
  default     = "Basic"
}

variable "zone_redundant" {
  description = "Enable zone redundancy for the database"
  type        = bool
  default     = false
}

# Managed Identity information
variable "managed_identity_name" {
  description = "Name of the managed identity for Azure AD authentication"
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

# Security and monitoring
variable "admin_emails" {
  description = "List of admin email addresses for security alerts"
  type        = list(string)
  default     = []
}

variable "security_storage_endpoint" {
  description = "Storage endpoint for security audit logs"
  type        = string
  default     = ""
}

variable "security_storage_access_key" {
  description = "Storage account access key for security audit logs"
  type        = string
  sensitive   = true
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
}