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

variable "virtual_network_id" {
  default = ""
}

variable "db_subnet_address_prefixes" {
  default = ""
}
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server

# specific (this: tssdb)
variable "postgresql_db_version" {
  default = "15"
}

variable "spotfire_db_instance_class" {
  default = "B_Standard_B2ms"
}

variable "spotfire_db_size" {
  description = "Flexible server: one of [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]"
  default = "32768"
}

# DB server login credentials
variable "spotfire_db_admin_username" {
  default = "dbadmin"
}

variable "spotfire_db_admin_password" {
  //  default = "d3f4ult!"
}