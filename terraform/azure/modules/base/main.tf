#----------------------------------------
# Base
#----------------------------------------

# Create a resource group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-spotfire-rg"
  location = var.location

  tags = var.tags
}

# Create an availability set
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set
resource "azurerm_availability_set" "this" {
  name                = "${var.prefix}-spotfire-avset"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  managed             = "true"

  tags = var.tags
}