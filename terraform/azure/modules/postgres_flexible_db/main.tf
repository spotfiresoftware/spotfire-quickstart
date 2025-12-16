#----------------------------------------
# Database (PostgreSQL)
#----------------------------------------

# Create a subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
variable "virtual_network_name" {
  default = ""
}
resource "azurerm_subnet" "db" {
  name                 = "${var.prefix}-spotfire-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.db_subnet_address_prefixes

  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
resource "azurerm_private_dns_zone" "db" {
  name                = "${var.prefix}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                = "${var.prefix}.com"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group_name

  depends_on = [
    azurerm_subnet.db
  ]
}

# https://docs.microsoft.com/en-us/rest/api/postgresql/
# https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview
# https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compare-single-server-flexible-server
# https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking#private-access-vnet-integration
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration
resource "azurerm_postgresql_flexible_server" "this" {
  name                = "${var.prefix}-spotfire-dbserver"
  location            = var.location
  resource_group_name = var.resource_group_name
  delegated_subnet_id = azurerm_subnet.db.id
  private_dns_zone_id = azurerm_private_dns_zone.db.id
  zone                = "1"

  administrator_login    = var.spotfire_db_admin_username
  administrator_password = var.spotfire_db_admin_password

  version    = var.postgresql_db_version
  sku_name   = var.spotfire_db_instance_class
  storage_mb = var.spotfire_db_size

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false
  public_network_access_enabled = false
#  infrastructure_encryption_enabled = false // This property is currently still in development and not supported by Microsoft.

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.db
  ]
}

# NOTE: This is an alternative way to do it, but the recommended is using private-access-vnet-integration, as above
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_virtual_network_rule
#resource "azurerm_postgresql_virtual_network_rule" "rds" {
#  name                                 = "${var.prefix}-postgresql-vnet-rule"
#  resource_group_name                  = var.resource_group_name
#  server_name                          = azurerm_postgresql_server.this.name
#  subnet_id                            = var.subnet_id
#  ignore_missing_vnet_service_endpoint = true
#}

# NOTE: This is not longer required. We use create-db to create spotfire_database
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database
#resource "azurerm_postgresql_flexible_server_database" "this" {
##  name                = "${var.prefix}-spotfire-db"
#  name                = var.spotfire_db_name
#  server_id           = azurerm_postgresql_flexible_server.this.id
#  charset             = "UTF8"
#  collation           = "en_US.utf8"
#}
