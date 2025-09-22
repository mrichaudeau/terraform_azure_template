# Required variables for AZD deployment
# These variables are automatically set by Azure Developer CLI

variable "environmentName" {
  description = "Name of the environment (set by AZD)"
  type        = string
}

variable "location" {
  description = "Azure region for deployment (set by AZD)"
  type        = string
}

variable "resourceGroupName" {
  description = "Name of the resource group (set by AZD)"
  type        = string
  default     = ""
}

# Optional variables with defaults
variable "sqlAdminPassword" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
  default     = null
}