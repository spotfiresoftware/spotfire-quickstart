output "rg_name" {
  value = azurerm_resource_group.this.name
}

output "availability_set_id" {
  value = azurerm_availability_set.this.id
}