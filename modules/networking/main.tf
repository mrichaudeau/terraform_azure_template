# Networking Module - VNet, Subnets, NSGs, and Private DNS
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Azure Naming Module for consistent naming
module "naming" {
  source = "Azure/naming/azurerm"
  suffix = [var.project_name, var.environment]
}

# Resource Group for Networking
resource "azurerm_resource_group" "networking" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = module.naming.virtual_network.name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

# App Service Subnet
resource "azurerm_subnet" "app" {
  name                 = "${module.naming.subnet.name}-app"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_cidrs.app]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Data Subnet for Private Endpoints
resource "azurerm_subnet" "data" {
  name                 = "${module.naming.subnet.name}-data"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_cidrs.data]
}

# Private Subnet for additional services
resource "azurerm_subnet" "private" {
  name                 = "${module.naming.subnet.name}-private"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_cidrs.private]
}

# Network Security Group for App Service
resource "azurerm_network_security_group" "app" {
  name                = "${module.naming.network_security_group.name}-app"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group for Data Subnet
resource "azurerm_network_security_group" "data" {
  name                = "${module.naming.network_security_group.name}-data"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

# Private DNS Zones for Private Endpoints
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

# Link Private DNS Zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "${module.naming.virtual_network.name}-sql-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  name                  = "${module.naming.virtual_network.name}-cosmos-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "${module.naming.virtual_network.name}-kv-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.tags
}