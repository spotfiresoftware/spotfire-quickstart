output "db_server" {
  value = azurerm_postgresql_server.this
}

output "db_name" {
  value = azurerm_postgresql_database.this.name
}
