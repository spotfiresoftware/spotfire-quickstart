#----------------------------------------
# Application Gateway
# - https://docs.microsoft.com/en-us/azure/application-gateway/
# - https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-faq
#----------------------------------------

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${var.vnet_name}-beap"
  frontend_port_name             = "${var.vnet_name}-feport"
  frontend_ip_configuration_name = "${var.vnet_name}-feip"
  http_setting_name              = "${var.vnet_name}-be-htst"
  listener_name                  = "${var.vnet_name}-httplstn"
  request_routing_rule_name      = "${var.vnet_name}-rqrt"
  redirect_configuration_name    = "${var.vnet_name}-rdrcfg"
}

resource "azurerm_subnet" "agw_subnet" {
  name                 = "${var.prefix}-spotfire-subnet-frontend"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.prefix}-spotfire-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
resource "azurerm_application_gateway" "network" {
  name                = "${var.prefix}-spotfire-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_http2 = true

  tags = var.tags

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agw_subnet.id
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
    ip_addresses = var.vm_nic_ip_addresses
  }
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    //    path                  = "/path1/"
    port            = 8080
    protocol        = "Http"
    request_timeout = 60
  }
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

//resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "this" {
//  network_interface_id    = var.tss_nic_ip_addresses
//  ip_configuration_name   = "tss-backend-pool"
//  backend_address_pool_id = azurerm_application_gateway.network.backend_address_pool[0].id
//}
