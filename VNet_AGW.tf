locals {
  backend_address_pool_name      = "${azurerm_virtual_network.spoke-aks-vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.spoke-aks-vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.spoke-aks-vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.spoke-aks-vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.spoke-aks-vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.spoke-aks-vnet.name}-rqrt"
}


#Create Application Gateway: Access AKS node pool (AppGW Public IP -> AppGW -> LoadBalancer -> (Nginx) -> Pod)

resource "azurerm_application_gateway" "appgw" {
  name                = "agw-${var.env}-${var.location}-spoke-aks"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = ["10.1.2.10"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  probe {
    name                                      = "http-health-probe"
    protocol                                  = "Http"
    pick_host_name_from_backend_http_settings = true
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    minimum_servers                           = 0
  }
}