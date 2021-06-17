output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "public_subnet_id" {
  value = azurerm_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private_subnet.id
}

output "nsg_id" {
  value = azurerm_network_security_group.this.id
}
