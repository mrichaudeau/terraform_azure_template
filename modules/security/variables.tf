# Variables for the security module

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

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Key Vault"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention period for Key Vault in days"
  type        = number
  default     = 7
  
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Key Vault soft delete retention must be between 7 and 90 days."
  }
}

variable "sql_connection_string" {
  description = "SQL Server connection string to store in Key Vault"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server admin password to store in Key Vault"
  type        = string
  sensitive   = true
  default     = null
}