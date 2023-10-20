#----------------------------------------
# Database (PostgreSQL)
#----------------------------------------

# https://docs.microsoft.com/en-us/rest/api/postgresql/
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server
resource "azurerm_postgresql_server" "this" {
  name                = "${var.prefix}-spotfire-dbserver"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.spotfire_db_admin_username
  administrator_login_password = var.spotfire_db_admin_password

  //  sku_name   = "GP_Gen5_4"
  sku_name   = var.spotfire_db_instance_class
  version    = var.postgresql_db_version
  storage_mb = var.spotfire_db_size

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled = true

  # https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies
  #  ssl_enforcement_enabled         = false
  #  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  # Needs to comply with policy: "Azure SQL Database should be running TLS version 1.2 or newer" (Error: 'Enable encryption')
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

#  infrastructure_encryption_enabled = false // This property is currently still in development and not supported by Microsoft.

  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_virtual_network_rule
resource "azurerm_postgresql_virtual_network_rule" "rds" {
  name                                 = "${var.prefix}-postgresql-vnet-rule"
  resource_group_name                  = var.resource_group_name
  server_name                          = azurerm_postgresql_server.this.name
  subnet_id                            = var.subnet_id
  ignore_missing_vnet_service_endpoint = true
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_database
resource "azurerm_postgresql_database" "this" {
  name                = "${var.prefix}-spotfire-db"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.this.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}