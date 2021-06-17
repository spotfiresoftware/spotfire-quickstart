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

#----------------------------------------
# specific (this: appgw)
variable "vnet_name" {
}

variable "agw_private_subnet_address_prefixes" {
  description = "Specify Application Gateway's SubNetwork address space"
  default = "10.0.3.0/30"
}

variable "vm_nic_ip_addresses" {
}
