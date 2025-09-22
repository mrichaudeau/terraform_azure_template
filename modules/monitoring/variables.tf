# Variables for the monitoring module

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

# Log Analytics configuration
variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 7 && var.log_retention_days <= 730
    error_message = "Log retention must be between 7 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily quota for Log Analytics workspace in GB (-1 for unlimited)"
  type        = number
  default     = -1
}

# Application Insights configuration
variable "app_insights_retention_days" {
  description = "Application Insights data retention in days"
  type        = number
  default     = 90
  
  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.app_insights_retention_days)
    error_message = "Application Insights retention must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730 days."
  }
}

variable "sampling_percentage" {
  description = "Sampling percentage for Application Insights (0-100)"
  type        = number
  default     = 100
  
  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

# Alerting configuration
variable "enable_alerts" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_smart_detection" {
  description = "Enable Application Insights smart detection"
  type        = bool
  default     = true
}

variable "alert_email_addresses" {
  description = "List of email addresses for alerts"
  type        = list(string)
  default     = []
}

# App Service ID for monitoring
variable "app_service_id" {
  description = "ID of the App Service to monitor"
  type        = string
  default     = ""
}