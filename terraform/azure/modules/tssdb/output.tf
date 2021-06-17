output "db_server" {
  value = azurerm_postgresql_server.postgresql_server
}

output "db_name" {
  value = azurerm_postgresql_database.postgresql_database.name
}
