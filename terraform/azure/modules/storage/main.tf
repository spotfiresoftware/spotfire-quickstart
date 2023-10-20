#----------------------------------------
# Storage account
#  - https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
# WARN: The Storage account name you choose must be unique across Azure,
#       can only consist of lowercase letters and numbers,
#       and must be between 3 and 24 characters long
resource "random_string" "storage_account" {
  length  = 24
  upper   = false
  numeric = true
  special = false
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  name                = random_string.storage_account.result
  resource_group_name = var.resource_group_name
  location            = var.location
  account_tier        = "Standard"
  account_kind        = "StorageV2" // required to connect the storage account to a private endpoint

  //  account_replication_type = "GRS" // Geo-redundant storage (GRS)
  account_replication_type = "LRS" // Locally redundant storage (LRS)

  tags = var.tags
}

# Need this to comply with policy: "Restrict network access to selected IP addresses"
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id = azurerm_storage_account.this.id
  default_action     = "Deny"
  ip_rules           = var.admin_address_prefixes //  List of public IP or IP ranges in CIDR Format
#  virtual_network_subnet_ids = var.subnet_id
#  bypass                     = ["AzureServices"]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "this" {
  name                 = "spotfire-share"
  storage_account_name = azurerm_storage_account.this.name
  quota                = 5 // max size in GB [0-5120GB]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_file
resource "azurerm_storage_share_file" "this" {
  name             = "ConfigureSSH.ps1"
  storage_share_id = azurerm_storage_share.this.id
  source           = "${path.module}/scripts/ConfigureSSH.ps1"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container
resource "azurerm_storage_container" "this" {
  name                  = "spotfire-swrepo"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob
resource "azurerm_storage_blob" "this" {
  name                   = "ConfigureSSH.ps1"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source                 = "${path.module}/scripts/ConfigureSSH.ps1"
}

//# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
//resource "azurerm_private_endpoint" "this" {
//  name                = "spotfireswrepo-endpoint"
//  resource_group_name = var.resource_group_name
//  location            = var.location
//  subnet_id           = var.subnet_id
//
//  private_service_connection {
//    name                           = "example-privateserviceconnection"
//    is_manual_connection           = false
//    private_connection_resource_id = azurerm_storage_account.this.id
//    subresource_names              = [ "file_secondary" ]
//  }
//}
