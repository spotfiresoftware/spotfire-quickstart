#----------------------------------------
# Networking
#----------------------------------------

# Create a virtual network within the resource group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "this" {
    name                = "${var.prefix}-spotfire-vnet"
    address_space       = [var.vnet_address_space]
    location            = var.location
    resource_group_name = var.resource_group_name

    tags = var.tags
}

# Create a subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "public_subnet" {
    name                 = "${var.prefix}-spotfire-public-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.this.name
    //    address_prefixes     = [cidrsubnet(var.vnet_address_space,8,1)]
    address_prefixes     = var.public_subnet_address_prefixes

//    service_endpoints    = ["Microsoft.Sql"] //, "Microsoft.Storage"]
    enforce_private_link_endpoint_network_policies = false
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "private_subnet" {
    name                 = "${var.prefix}-spotfire-private-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.this.name
//    address_prefixes     = [cidrsubnet(var.vnet_address_space,8,1)]
    address_prefixes     = var.private_subnet_address_prefixes

    service_endpoints    = ["Microsoft.Sql"] //, "Microsoft.Storage"]
    enforce_private_link_endpoint_network_policies = false
}

# Create Network Security Group and SSH rule for public subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "this" {
    name                = "${var.prefix}-spotfire-nsg"
    location            = var.location
    resource_group_name = var.resource_group_name

    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges     = var.inbound_ports_to_allow
//        source_address_prefix      = "85.0.0.0/8"
        source_address_prefix      = var.source_address_prefix
        destination_address_prefix = "*"
    }

    tags = var.tags
}

# Associate network security group with public subnet
# - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "public_subnet_assoc" {
    subnet_id                 = azurerm_subnet.public_subnet.id
    network_security_group_id = azurerm_network_security_group.this.id
}
