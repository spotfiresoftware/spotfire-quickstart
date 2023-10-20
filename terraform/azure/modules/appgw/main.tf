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
  //address_prefixes     = ["10.1.0.0/16"]
  address_prefixes     = var.appgw_subnet_address_prefixes
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.prefix}-spotfire-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  # Application Gateway v2 only supports public IP address.
  # Application Gateway v2 does not allow sku "Basic"
  sku      = "Standard"
  sku_tier = "Regional"

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
    # differences between V1 and V2. https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-autoscaling-zone-redundant#differences-with-v1-sku
    # States ILB Mode only is not supported on V2.
    # The Frontend IP Address has to be a public. This is what I get when I try to create the Application Gateway v2 with a private ip address.
    # "Application Gateways with a tier of Standard_v2 don’t support only private IP addresses as the frontend. Supported SKU tiers are standard and WAF."

    # Update: 202306: Application Gateway v1 is deprecated. See https://aka.ms/V1retirement
    #    name     = "Standard_Small"
    #    tier     = "Standard" // deprecated
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
  probe {
    name = "login-check"
    protocol = "Http"
    #port = 80 # not supported for SKU tier Standard.
    interval = 30
    timeout  = 30
    path = "/spotfire/login.html"
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
  }

  depends_on = [
    azurerm_public_ip.appgw_pip
  ]

}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_gateway_backend_address_pool_association
#resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "this" {
#  network_interface_id    = var.vm_nic_ip_addresses
#  ip_configuration_name   = "tss-backend-pool"
#  backend_address_pool_id = azurerm_application_gateway.network.backend_address_pool[0].id
#}
