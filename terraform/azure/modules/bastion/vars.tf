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

# networking
variable "vnet_name" {
  default = ""
}

#----------------------------------------
# specific (this: bastion)
variable "bastion_subnet_address_prefixes" {
  description = "Specify bastion subnet addresses"
  default     = ["10.0.0.0/30"]
}
