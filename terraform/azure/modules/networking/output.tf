output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

