resource "azurerm_frontdoor" "afd" {
  name                = "${var.base_name}-afd"
  resource_group_name = azurerm_resource_group.rg.name
  #location            = "Global"

  enforce_backend_pools_certificate_name_check = true

  routing_rule {
    name               = "default-route"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*", "/"]
    frontend_endpoints = ["${var.base_name}-afd-lb"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = azurerm_app_service.app.name
    }
  }

  backend_pool_load_balancing {
    name = "${var.base_name}-afd-lb"
  }

  backend_pool_health_probe {
    name = "${var.base_name}-afd-ph"
  }

  backend_pool {
    name                = azurerm_app_service.app.name
    load_balancing_name = "${var.base_name}-afd-lb"
    health_probe_name   = "${var.base_name}-afd-ph"

    backend {
      host_header = azurerm_app_service.app.default_site_hostname
      address     = azurerm_app_service.app.default_site_hostname
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
    }
  }

  frontend_endpoint {
    name                              = "${var.base_name}-afd-lb"
    host_name                         = "${var.base_name}-afd.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}