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

variable "jumphost_public_ips" {}

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

//variable "admin_open_tcp_ports" {
//  description = "Firewall/Security Group ports to allow for inbound traffic. By default ssh is allowed"
//  default     = [22, 80, 433]
//}

variable "admin_address_prefixes" {
  description = "CIDR or source IP range allowed for remote access"
  default     = ["43.21.0.0/16"]
}

variable "web_address_prefixes" {
  description = "CIDR or source IP range allowed for remote access for Spotfire application"
  default     = ["43.0.0.0/8"]
}
