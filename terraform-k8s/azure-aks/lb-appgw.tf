#----------------------------------------
# Application Gateway
# - https://docs.microsoft.com/en-us/azure/application-gateway/
# - https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-faq
#----------------------------------------

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${local.vnet_name}-beap"
  frontend_port_name             = "${local.vnet_name}-feport"
  frontend_ip_configuration_name = "${local.vnet_name}-feip"
  http_setting_name              = "${local.vnet_name}-be-htst"
  listener_name                  = "${local.vnet_name}-httplstn"
  request_routing_rule_name      = "${local.vnet_name}-rqrt"
  redirect_configuration_name    = "${local.vnet_name}-rdrcfg"
}

locals {
  resource_group_name = azurerm_resource_group.this.name
  vnet_name           = azurerm_virtual_network.this.name
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "agw_subnet" {
  name                 = "${var.prefix}-appgw-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.appgw_subnet_address_prefixes
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.prefix}-k8s-pip"
  resource_group_name = local.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  # Application Gateway v2 only supports public IP address.
  # Application Gateway v2 requires sku "Standard"
  sku      = "Standard"
  sku_tier = "Regional"

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
resource "azurerm_application_gateway" "network" {
  name                = "${var.prefix}-k8s-appgw"
  resource_group_name = local.resource_group_name
  location            = var.location

  enable_http2 = true

  tags = var.tags

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
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
  frontend_port {
    name = "httpsPort"
    port = 443
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }
  backend_address_pool {
    name         = local.backend_address_pool_name
#    ip_addresses = var.vm_nic_ip_addresses
  }
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Enabled"
    //    path                  = "/path1/"
    port            = 80
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
    priority                   = 9 // required when sku.0.tier is set to *_v2
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
#  probe {
#    name = "login-check"
#    protocol = "Http"
#    #port = 80 # not supported for SKU tier Standard.
#    interval = 30
#    timeout  = 30
#    path = "/spotfire/login.html"
#    unhealthy_threshold = 3
#    pick_host_name_from_backend_http_settings = true
#  }

  depends_on = [
    azurerm_public_ip.appgw_pip
  ]

}
