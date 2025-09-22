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

variable "app_service_id" {
  description = "ID of the App Service to monitor"
  type        = string
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "app_service_url" {
  description = "URL of the App Service for availability testing"
  type        = string
  default     = null
}

variable "sql_database_id" {
  description = "ID of the SQL Database to monitor"
  type        = string
  default     = null
}

variable "cosmos_account_id" {
  description = "ID of the Cosmos DB Account to monitor"
  type        = string
  default     = null
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition = contains([
      "Free", "PerNode", "Premium", "Standard", "Standalone", 
      "Unlimited", "CapacityReservation", "PerGB2018"
    ], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be a valid SKU."
  }
}

variable "log_analytics_retention_days" {
  description = "Retention period for Log Analytics workspace in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

variable "enable_alerts" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = true
}

variable "enable_availability_test" {
  description = "Enable Application Insights availability test"
  type        = bool
  default     = true
}

variable "create_dashboard" {
  description = "Create monitoring dashboard"
  type        = bool
  default     = true
}

variable "alert_email_addresses" {
  description = "List of email addresses for alert notifications"
  type        = list(string)
  default     = []
}

variable "alert_sms_numbers" {
  description = "List of SMS numbers for alert notifications"
  type = list(object({
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "cpu_alert_threshold" {
  description = "CPU percentage threshold for alerts"
  type        = number
  default     = 80
}

variable "memory_alert_threshold" {
  description = "Memory percentage threshold for alerts"
  type        = number
  default     = 80
}

variable "response_time_alert_threshold" {
  description = "Response time threshold for alerts (in seconds)"
  type        = number
  default     = 5
}

variable "sql_dtu_alert_threshold" {
  description = "SQL Database DTU percentage threshold for alerts"
  type        = number
  default     = 80
}

variable "cosmos_ru_alert_threshold" {
  description = "Cosmos DB request units threshold for alerts"
  type        = number
  default     = 1000
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}