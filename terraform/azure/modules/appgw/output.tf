output "appgw_pip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}