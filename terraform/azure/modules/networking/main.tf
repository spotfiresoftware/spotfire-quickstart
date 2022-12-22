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
resource "azurerm_subnet" "public" {
  name                 = "${var.prefix}-spotfire-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  //address_prefixes     = [cidrsubnet(var.vnet_address_space,8,1)]
  address_prefixes = var.public_subnet_address_prefixes

  //service_endpoints    = ["Microsoft.Sql"] //, "Microsoft.Storage"]
  //enforce_private_link_endpoint_network_policies = false
  private_endpoint_network_policies_enabled = false
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "private" {
  name                 = "${var.prefix}-spotfire-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  //    address_prefixes     = [cidrsubnet(var.vnet_address_space,8,1)]
  address_prefixes = var.private_subnet_address_prefixes

  service_endpoints                              = ["Microsoft.Sql"] //, "Microsoft.Storage"]
  //enforce_private_link_endpoint_network_policies = false
  private_endpoint_network_policies_enabled = false
}

# Create Network Security Group and SSH rule for public subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "public" {
  name                = "${var.prefix}-spotfire-public-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # azurerm_network_security_rule can stand on its own there are many rules for better management
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule
  security_rule {
    name                       = "Allow management (SSH, RDP) from admin IPs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [22, 3389]
    source_address_prefixes    = var.admin_address_prefixes
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate network security group with public subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "public_subnet_assoc" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Create Network Security Group and SSH rule for private subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "private" {
  name                = "${var.prefix}-spotfire-private-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # azurerm_network_security_rule can stand on its own, there are many rules for better management
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule
  security_rule {
    name                       = "Allow management (SSH, RDP) from admin IPs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [22, 3389]
    source_address_prefixes    = var.admin_address_prefixes
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow management (SSH, RDP) from jumphost public ips"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [22, 3389]
    source_address_prefixes    = var.jumphost_public_ips
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow web access (8080, 8433) from web IPs"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [8080, 8433]
    source_address_prefixes    = var.web_address_prefixes
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow web access (8080, 8433) from admin IPs"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [8080, 8433]
    source_address_prefixes    = var.admin_address_prefixes
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow web access (8080, 8433) from appgw IPs"
    priority                   = 112
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [8080, 8433]
    source_address_prefixes    = var.appgw_subnet_address_prefixes
    destination_address_prefix = "*"
  }
  tags = var.tags
}

# Associate network security group with public subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "private_subnet_assoc" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}
