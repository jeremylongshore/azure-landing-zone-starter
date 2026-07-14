# Hub VNet: application + data tiers
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.name_prefix}-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_app_subnet_prefix]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_data_subnet_prefix]
}

# Spoke VNet: stand-in for on-prem / external connectivity.
# Production would use ExpressRoute or VPN Gateway here — those are not free-tier.
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.name_prefix}-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.spoke_address_space
  tags                = merge(var.tags, { role = "on-prem-stand-in" })
}

resource "azurerm_subnet" "spoke" {
  name                 = "snet-onprem"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spoke_subnet_prefix]
}

# --- NSG: app subnet ---
# Allow HTTPS/HTTP only from the spoke (on-prem stand-in). Not wide open.
resource "azurerm_network_security_group" "app" {
  name                = "nsg-${var.name_prefix}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowHTTPSFromSpoke"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.spoke_subnet_prefix
    destination_address_prefix = var.hub_app_subnet_prefix
  }

  security_rule {
    name                       = "AllowHTTPFromSpoke"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.spoke_subnet_prefix
    destination_address_prefix = var.hub_app_subnet_prefix
  }

  security_rule {
    name                       = "DenyInboundFromInternet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# --- NSG: data subnet ---
# Only app subnet may reach data ports. No internet ingress.
resource "azurerm_network_security_group" "data" {
  name                = "nsg-${var.name_prefix}-data"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowPostgresFromApp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.hub_app_subnet_prefix
    destination_address_prefix = var.hub_data_subnet_prefix
  }

  security_rule {
    name                       = "AllowSqlFromApp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.hub_app_subnet_prefix
    destination_address_prefix = var.hub_data_subnet_prefix
  }

  security_rule {
    name                       = "DenySpokeToData"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.spoke_subnet_prefix
    destination_address_prefix = var.hub_data_subnet_prefix
  }

  security_rule {
    name                       = "DenyInboundFromInternet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# --- NSG: spoke subnet ---
resource "azurerm_network_security_group" "spoke" {
  name                = "nsg-${var.name_prefix}-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowOutboundHTTPSToHubApp"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.spoke_subnet_prefix
    destination_address_prefix = var.hub_app_subnet_prefix
  }

  security_rule {
    name                       = "DenyOutboundToData"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.spoke_subnet_prefix
    destination_address_prefix = var.hub_data_subnet_prefix
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

resource "azurerm_subnet_network_security_group_association" "spoke" {
  subnet_id                 = azurerm_subnet.spoke.id
  network_security_group_id = azurerm_network_security_group.spoke.id
}

# Bidirectional VNet peering (hub <-> spoke)
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-spoke"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
