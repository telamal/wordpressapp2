resource "azurerm_app_service_plan" "plan" {
  name                = "${var.base_name}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  kind             = "Linux"
  reserved         = true

  sku {
    tier = "PremiumV3"
    size = "P1v3"
  }
}

resource "azurerm_app_service" "app" {
  name                       = "${var.base_name}-app"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id

  site_config {
    always_on        = true
    linux_fx_version = "DOCKER|cwiederspan/mywordpress"
    ftps_state       = "Disabled"

    ip_restriction = [
      {
        name        = "Allow AFD"
        action      = "Allow"
        priority    = 100
        service_tag = "AzureFrontDoor.Backend"
        ip_address  = null
        subnet_id   = null
        virtual_network_subnet_id = null
      }
    ]
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITE_VNET_ROUTE_ALL              = 1

    WORDPRESS_DB_HOST      = azurerm_mysql_server.mysql.fqdn
    WORDPRESS_DB_USER      = "${var.db_username}@${azurerm_mysql_server.mysql.name}"
    WORDPRESS_DB_PASSWORD  = azurerm_mysql_server.mysql.administrator_login_password
    #WORDPRESS_CONFIG_EXTRA = "define('FS_METHOD','direct');\ndefine('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);"
    WORDPRESS_CONFIG_EXTRA = "define('FS_METHOD','direct');\ndefine('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);\ndefine('WP_HOME', 'https://${var.base_name}-afd.azurefd.net');\ndefine('WP_SITEURL', 'https://${var.base_name}-afd.azurefd.net');"
  }

  storage_account {
    name         = "wpcontent"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.storage.name
    share_name   = azurerm_storage_share.wpcontent.name
    access_key   = azurerm_storage_account.storage.primary_access_key
    mount_path   = "/var/www/html/wp-content"
  }

  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled  = true
    
    #application_logs { }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  /*
  depends_on = [
    azurerm_storage_account.storage,
    azurerm_storage_share.wpcontent,
    azurerm_private_endpoint.fspe
  ]
  */
}

resource "azurerm_app_service_virtual_network_swift_connection" "injection" {
  app_service_id = azurerm_app_service.app.id
  subnet_id      = azurerm_subnet.web.id
}