# -----------------------------
# Public IP (for App Gateway)
# -----------------------------
resource "azurerm_public_ip" "burgerbuilder_appgw_pip" {
  name                = "burgerbuilder-appgw-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project     = "BurgerBuilder"
    Environment = "Production"
    Owner       = "alrasheed10"
  }
}

# -----------------------------
# Application Gateway (Standard v2, HTTP only)
# -----------------------------
resource "azurerm_application_gateway" "burgerbuilder_appgw" {
  name                = "burgerbuilder-appgw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendPublicIp"
    public_ip_address_id = azurerm_public_ip.burgerbuilder_appgw_pip.id
  }

  backend_address_pool {
    name  = "frontendPool"
    fqdns = ["burgerbuilder-frontend.nicebeach-3608a673.swedencentral.azurecontainerapps.io"]
  }

  backend_address_pool {
    name  = "backendPool"
    fqdns = ["burgerbuilder-backend.nicebeach-3608a673.swedencentral.azurecontainerapps.io"]
  }

  probe {
    name                                      = "frontend-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  probe {
    name                                      = "backend-probe"
    protocol                                  = "Https"
    path                                      = "/actuator/health"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  backend_http_settings {
    name                                = "frontendHttpSetting"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "frontend-probe"
    cookie_based_affinity               = "Disabled"
  }

  backend_http_settings {
    name                                = "backendHttpSetting"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "backend-probe"
    cookie_based_affinity               = "Disabled"
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "frontendPublicIp"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  url_path_map {
    name = "pathBasedRouting"

    default_backend_address_pool_name  = "frontendPool"
    default_backend_http_settings_name = "frontendHttpSetting"

    path_rule {
      name                       = "apiRule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backendPool"
      backend_http_settings_name = "backendHttpSetting"
    }
  }

  request_routing_rule {
    name               = "pathBasedRule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "httpListener"
    url_path_map_name  = "pathBasedRouting"
    priority           = 100
  }

  tags = {
    Project     = "BurgerBuilder"
    Environment = "Production"
    Owner       = "alrasheed10"
  }
}