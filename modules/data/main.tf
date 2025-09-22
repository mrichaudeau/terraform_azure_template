# Data Module - Azure SQL Database and Cosmos DB
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Azure Naming Module
module "naming" {
  source = "Azure/naming/azurerm"
  suffix = [var.project_name, var.environment]
}

# Random suffix for globally unique resources
resource "random_string" "sql_suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "random_string" "cosmos_suffix" {
  length  = 4
  upper   = false
  special = false
}

# Random password for SQL Admin (will be stored in Key Vault)
resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
}

# Resource Group for Data Services
resource "azurerm_resource_group" "data" {
  name     = "${module.naming.resource_group.name}-data"
  location = var.location
  tags     = var.tags
}

# Azure SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${module.naming.mssql_server.name}${random_string.sql_suffix.result}"
  resource_group_name          = azurerm_resource_group.data.name
  location                     = azurerm_resource_group.data.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_admin_password.result
  
  # Disable public network access - use private endpoint
  public_network_access_enabled = false
  
  tags = var.tags

  azuread_administrator {
    login_username              = var.azuread_admin_login
    object_id                   = var.azuread_admin_object_id
    tenant_id                   = var.azuread_admin_tenant_id
    azuread_authentication_only = false
  }
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = var.sql_database_sku
  zone_redundant = var.environment == "prod" ? true : false
  
  tags = var.tags

  # Backup configuration
  short_term_retention_policy {
    retention_days = var.environment == "prod" ? 35 : 7
  }

  long_term_retention_policy {
    weekly_retention  = var.environment == "prod" ? "P12W" : null
    monthly_retention = var.environment == "prod" ? "P12M" : null
    yearly_retention  = var.environment == "prod" ? "P5Y" : null
    week_of_year      = var.environment == "prod" ? 1 : null
  }
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql" {
  name                = "${module.naming.private_endpoint.name}-sql"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  subnet_id           = var.data_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${module.naming.private_endpoint.name}-sql-connection"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [var.sql_private_dns_zone_id]
  }
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                      = "${module.naming.cosmosdb_account.name}${random_string.cosmos_suffix.result}"
  location                  = azurerm_resource_group.data.location
  resource_group_name       = azurerm_resource_group.data.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = var.environment == "prod" ? true : false
  
  # Disable public network access - use private endpoint
  public_network_access_enabled = false
  
  consistency_policy {
    consistency_level       = var.cosmos_consistency_level
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.environment == "prod" ? true : false
  }

  # Add secondary region for production
  dynamic "geo_location" {
    for_each = var.environment == "prod" && var.cosmos_secondary_region != null ? [1] : []
    content {
      location          = var.cosmos_secondary_region
      failover_priority = 1
      zone_redundant    = true
    }
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = var.environment == "prod" ? 240 : 1440
    retention_in_hours  = var.environment == "prod" ? 720 : 168
    storage_redundancy  = var.environment == "prod" ? "Geo" : "Local"
  }
  
  tags = var.tags
}

# Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = var.cosmos_database_name
  resource_group_name = azurerm_resource_group.data.name
  account_name        = azurerm_cosmosdb_account.main.name
  
  # Autoscale for production, manual for dev/staging
  dynamic "autoscale_settings" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      max_throughput = var.cosmos_max_throughput
    }
  }
  
  throughput = var.environment != "prod" ? var.cosmos_throughput : null
}

# Cosmos DB Container for FastAPI data
resource "azurerm_cosmosdb_sql_container" "fastapi_data" {
  name                  = "fastapi-data"
  resource_group_name   = azurerm_resource_group.data.name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.main.name
  partition_key_path    = "/id"
  partition_key_version = 1
  
  # Autoscale for production, manual for dev/staging
  dynamic "autoscale_settings" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      max_throughput = var.cosmos_container_max_throughput
    }
  }
  
  throughput = var.environment != "prod" ? var.cosmos_container_throughput : null

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }

  unique_key {
    paths = ["/email"]
  }
}

# Private Endpoint for Cosmos DB
resource "azurerm_private_endpoint" "cosmos" {
  name                = "${module.naming.private_endpoint.name}-cosmos"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  subnet_id           = var.data_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${module.naming.private_endpoint.name}-cosmos-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "cosmos-dns-zone-group"
    private_dns_zone_ids = [var.cosmos_private_dns_zone_id]
  }
}