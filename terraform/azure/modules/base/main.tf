#----------------------------------------
# Base
#----------------------------------------

# Create a resource group
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-spotfire-rg"
  location = var.location

  tags = var.tags
}

# Create an availability set
resource "azurerm_availability_set" "this" {
  name                = "${var.prefix}-spotfire-avset"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  managed             = "true"

  tags = var.tags
}
