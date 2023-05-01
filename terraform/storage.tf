/*
# Use this for Standardv2 Storage account (vs. Premium)
resource "azurerm_storage_account" "storage" {
  name                     = replace(var.base_name, "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
*/

# Premium Storage Account for storing the site content
resource "azurerm_storage_account" "storage" {
  name                     = replace(var.base_name, "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

# Firewall the storage account using Service Endpoints
resource "azurerm_storage_account_network_rules" "fsse" {
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_name = azurerm_storage_account.storage.name

  default_action             = "Deny"
  ip_rules                   = [ ]
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [ azurerm_subnet.web.id ]
}

# Create the file share within the storage account
resource "azurerm_storage_share" "wpcontent" {
  name                 = "wpcontent"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 100
}

/*
# Used for setting up Private Endpoints to the storage account.
# This currently does not work because file mounting for app services
# does not support VNET integration/private link, so it must mount
# over the public interface.
resource "azurerm_private_endpoint" "fspe" {
  name                = "${var.base_name}-fspe"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.backend.id

  private_service_connection {
    name                           = "${var.base_name}-fspe"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.base_name}-fspe"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnstorage.id]
  }
}
*/