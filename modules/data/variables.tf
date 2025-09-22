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

variable "data_subnet_id" {
  description = "ID of the data subnet for private endpoints"
  type        = string
}

variable "sql_private_dns_zone_id" {
  description = "ID of the SQL private DNS zone"
  type        = string
}

variable "cosmos_private_dns_zone_id" {
  description = "ID of the Cosmos DB private DNS zone"
  type        = string
}

variable "sql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = "sqladmin"
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
  validation {
    condition = contains([
      "Basic", "S0", "S1", "S2", "S3", "S4", "S6", "S7", "S9", "S12",
      "P1", "P2", "P4", "P6", "P11", "P15"
    ], var.sql_database_sku)
    error_message = "SQL database SKU must be a valid Azure SQL Database SKU."
  }
}

variable "azuread_admin_login" {
  description = "Azure AD admin login for SQL Server"
  type        = string
}

variable "azuread_admin_object_id" {
  description = "Azure AD admin object ID for SQL Server"
  type        = string
}

variable "azuread_admin_tenant_id" {
  description = "Azure AD admin tenant ID for SQL Server"
  type        = string
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
  validation {
    condition = contains([
      "BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"
    ], var.cosmos_consistency_level)
    error_message = "Cosmos DB consistency level must be one of: BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix."
  }
}

variable "cosmos_throughput" {
  description = "Throughput for Cosmos DB database (manual scaling)"
  type        = number
  default     = 400
}

variable "cosmos_max_throughput" {
  description = "Maximum throughput for Cosmos DB database (autoscale)"
  type        = number
  default     = 4000
}

variable "cosmos_container_throughput" {
  description = "Throughput for Cosmos DB container (manual scaling)"
  type        = number
  default     = 400
}

variable "cosmos_container_max_throughput" {
  description = "Maximum throughput for Cosmos DB container (autoscale)"
  type        = number
  default     = 4000
}

variable "cosmos_secondary_region" {
  description = "Secondary region for Cosmos DB (production only)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}