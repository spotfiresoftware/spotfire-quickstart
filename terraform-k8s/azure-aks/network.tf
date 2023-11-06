#----------------------------------------
# Networking
#----------------------------------------
resource "azurerm_resource_group" "this" {
  #  name     = "${random_pet.prefix.id}-rg"
  name     = "${var.prefix}-rg"
  location = var.region

  tags = var.tags
}

# Create a virtual network within the resource group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-vnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_address_space]

  tags = var.tags
}

# Create a subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "k8s_subnet" {
  name                 = "${var.prefix}-private-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.k8s_subnet_address_prefixes

  private_endpoint_network_policies_enabled = true
  service_endpoints = ["Microsoft.ContainerRegistry"]
}
