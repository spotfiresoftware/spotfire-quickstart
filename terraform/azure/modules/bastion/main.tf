#----------------------------------------
# Bastion host
#----------------------------------------

# Refs:
# - https://en.wikipedia.org/wiki/Bastion_host
# - https://docs.microsoft.com/en-us/azure/bastion/bastion-overview
# - https://azure.microsoft.com/en-us/services/azure-bastion/


# - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host
resource "azurerm_subnet" "this" {
  # WARN: Azure Bastion can only be created in subnet with name 'AzureBastionSubnet'
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.bastion_subnet_address_prefixes
}

resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "${var.prefix}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.this.id
    public_ip_address_id = azurerm_public_ip.this.id
  }

  tags = var.tags
}
