output "db_server" {
  value = azurerm_postgresql_flexible_server.this
}

#output "db_name" {
#  value = azurerm_postgresql_flexible_server_database.this.name
#}

# networking
output "db_subnet_id" {
  value = azurerm_subnet.db.id
}
