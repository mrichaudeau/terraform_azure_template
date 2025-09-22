# Networking module for Python SQL Web App
# Creates VNet, subnets, NSGs, and private endpoints

# Virtual Network
resource "azurecaf_name" "vnet" {
  name          = var.project_name
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.environment_name]
}

resource "azurerm_virtual_network" "main" {
  name                = azurecaf_name.vnet.result
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

# Subnets
resource "azurecaf_name" "subnet_webapp" {
  name          = "${var.project_name}-webapp"
  resource_type = "azurerm_subnet"
  suffixes      = [var.environment_name]
}

resource "azurerm_subnet" "webapp" {
  name                 = azurecaf_name.subnet_webapp.result
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_cidrs.webapp]

  # Delegation for App Service VNet integration
  delegation {
    name = "webapp-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurecaf_name" "subnet_private_endpoints" {
  name          = "${var.project_name}-pe"
  resource_type = "azurerm_subnet"
  suffixes      = [var.environment_name]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = azurecaf_name.subnet_private_endpoints.result
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_cidrs.private_endpoints]
}

# Network Security Groups
resource "azurecaf_name" "nsg_webapp" {
  name          = "${var.project_name}-webapp"
  resource_type = "azurerm_network_security_group"
  suffixes      = [var.environment_name]
}

resource "azurerm_network_security_group" "webapp" {
  name                = azurecaf_name.nsg_webapp.result
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTPS inbound from Internet
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow HTTP inbound from Internet (for redirect to HTTPS)
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow outbound to SQL subnet
  security_rule {
    name                       = "AllowSQLOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = var.subnet_cidrs.private_endpoints
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "webapp" {
  subnet_id                 = azurerm_subnet.webapp.id
  network_security_group_id = azurerm_network_security_group.webapp.id
}

resource "azurecaf_name" "nsg_private_endpoints" {
  name          = "${var.project_name}-pe"
  resource_type = "azurerm_network_security_group"
  suffixes      = [var.environment_name]
}

resource "azurerm_network_security_group" "private_endpoints" {
  name                = azurecaf_name.nsg_private_endpoints.result
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow inbound from web app subnet to SQL
  security_rule {
    name                       = "AllowWebAppToSQL"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.subnet_cidrs.webapp
    destination_address_prefix = "*"
  }

  # Allow HTTPS to Key Vault
  security_rule {
    name                       = "AllowWebAppToKeyVault"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.subnet_cidrs.webapp
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "sql" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Link private DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  count                 = var.enable_private_endpoints ? 1 : 0
  name                  = "${azurecaf_name.vnet.result}-sql-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql[0].name
  virtual_network_id    = azurerm_virtual_network.main.id

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  count                 = var.enable_private_endpoints ? 1 : 0
  name                  = "${azurecaf_name.vnet.result}-kv-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault[0].name
  virtual_network_id    = azurerm_virtual_network.main.id

  tags = var.tags
}

# Private Endpoints (created by other modules, DNS records created here)
resource "azurerm_private_endpoint" "sql" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.sql_server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.sql_server_name}-psc"
    private_connection_resource_id = var.sql_server_id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = var.enable_private_endpoints ? [azurerm_private_dns_zone.sql[0].id] : []
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "keyvault" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = var.key_vault_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = var.enable_private_endpoints ? [azurerm_private_dns_zone.keyvault[0].id] : []
  }

  tags = var.tags
}