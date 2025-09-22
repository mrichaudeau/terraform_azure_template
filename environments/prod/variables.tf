# Production Environment Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fastapi-app"
  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.project_name))
    error_message = "Project name must be 2-20 characters long, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Operations Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "IT-Production"
}

variable "business_unit" {
  description = "Business unit"
  type        = string
  default     = "Engineering"
}

# Networking Variables
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = object({
    app     = string
    data    = string
    private = string
  })
  default = {
    app     = "10.2.1.0/24"
    data    = "10.2.2.0/24"
    private = "10.2.3.0/24"
  }
}

# Database Variables
variable "sql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_database_name" {
  description = "Name of the SQL database"
  type        = string
  default     = "fastapi-db"
}

variable "sql_database_sku" {
  description = "SKU for the SQL database"
  type        = string
  default     = "P2"
}

variable "cosmos_database_name" {
  description = "Name of the Cosmos database"
  type        = string
  default     = "fastapi-cosmos-db"
}

variable "cosmos_consistency_level" {
  description = "Consistency level for Cosmos DB"
  type        = string
  default     = "Session"
}

variable "cosmos_max_throughput" {
  description = "Maximum throughput for Cosmos DB database (autoscale)"
  type        = number
  default     = 10000
}

variable "cosmos_container_max_throughput" {
  description = "Maximum throughput for Cosmos DB container (autoscale)"
  type        = number
  default     = 10000
}

variable "cosmos_secondary_region" {
  description = "Secondary region for Cosmos DB"
  type        = string
  default     = "West US 2"
}

variable "azuread_admin_login" {
  description = "Azure AD admin login for SQL Server"
  type        = string
  default     = "sqladmin@yourdomain.com"
}

variable "azuread_admin_object_id" {
  description = "Azure AD admin object ID for SQL Server"
  type        = string
}

# App Service Variables
variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "P1v3"
}

variable "public_network_access_enabled" {
  description = "Enable public network access for App Service"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["https://yourdomain.com", "https://api.yourdomain.com"]
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
  default     = 2
}

variable "autoscale_max_instances" {
  description = "Maximum number of instances for autoscaling"
  type        = number
  default     = 10
}

# Monitoring Variables
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

variable "cpu_alert_threshold" {
  description = "CPU percentage threshold for alerts"
  type        = number
  default     = 70
}

variable "memory_alert_threshold" {
  description = "Memory percentage threshold for alerts"
  type        = number
  default     = 70
}

variable "response_time_alert_threshold" {
  description = "Response time threshold for alerts (in seconds)"
  type        = number
  default     = 3
}

variable "sql_dtu_alert_threshold" {
  description = "SQL Database DTU percentage threshold for alerts"
  type        = number
  default     = 70
}

variable "cosmos_ru_alert_threshold" {
  description = "Cosmos DB request units threshold for alerts"
  type        = number
  default     = 800
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