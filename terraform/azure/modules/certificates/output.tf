output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "cert_secret_id" {
  value = azurerm_key_vault_certificate.this.secret_id
}

output "key_vault_key" {
  value = azurerm_key_vault_key.this.id
}