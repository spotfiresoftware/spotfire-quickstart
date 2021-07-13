# common
variable "prefix" {
  default = "sandbox"
}

variable "location" {
  default = "North Europe"
}

variable "tags" {
  type = map(string)

  default = {
    env  = "dev"
    tier = "infra"
    app  = "Spotfire"
  }
}

# base
variable "resource_group_name" {
  description = "Specify the resource group name"
}

//variable "availability_set_id" {
//  default = ""
//}

#----------------------------------------
# specific (this: networking)
variable "vnet_address_space" {
  description = "Specify VirtualNetwork address space"
  default     = "10.0.0.0/16"
}

variable "public_subnet_address_prefixes" {
  description = "Define subnet address block here"
  //  default = "${cidrsubnet("${var.vnet_address_space}",4,1)}"
  //  default     = [cidrsubnet(var.vnet_address_space,14,1)]
}

variable "private_subnet_address_prefixes" {
  description = "Define subnet address block here"
  //  default = "${cidrsubnet("${var.vnet_address_space}",4,1)}"
  //  default     = [cidrsubnet(var.vnet_address_space,8,2)]
}

variable "inbound_ports_to_allow" {
  description = "Firewall/Security Group ports to allow for inbound traffic. By default ssh is allowed"
  default     = [22, 80, 433]
}

variable "admin_address_prefix" {
  description = "CIDR or source IP range allowed for remote access"
  default     = "43.21.0.0/16"
}
