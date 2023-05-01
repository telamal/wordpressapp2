resource "azurerm_virtual_network" "vnet" {
  name                = "${var.base_name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "web-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.2.0/24"]

  enforce_private_link_endpoint_network_policies = true
  # enforce_private_link_service_network_policies  = true
}

resource "azurerm_private_dns_zone" "dnsdb" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnsdbvnetlink" {
  name                  = "dnsdbvnetlink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdb.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
/*
resource "azurerm_private_dns_zone" "dnstorage" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnsstoragevnetlink" {
  name                  = "dnsstoragevnetlink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnstorage.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
*/