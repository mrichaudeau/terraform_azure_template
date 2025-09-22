# Development Environment Variables

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
  default     = "Development Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "IT-Development"
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
  default     = ["10.0.0.0/16"]
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = object({
    app     = string
    data    = string
    private = string
  })
  default = {
    app     = "10.0.1.0/24"
    data    = "10.0.2.0/24"
    private = "10.0.3.0/24"
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
  default     = "S0"
}

variable "cosmos_database_name" {
  description = "Name of the Cosmos database"
  type        = string
  default     = "fastapi-cosmos-db"
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
  default     = "B1"
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
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