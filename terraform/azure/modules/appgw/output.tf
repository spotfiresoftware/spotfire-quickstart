output "appgw_pip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}
output "appgw_subnet_address_prefixes" {
  value = azurerm_subnet.agw_subnet.address_prefixes
}