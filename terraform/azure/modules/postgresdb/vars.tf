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
variable "subnet_id" {
  default = ""
}

#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server

# specific (this: sfdb)
variable "postgresql_db_version" {
  default = "11"
}

variable "spotfire_db_instance_class" {
  default = "GP_Gen5_2"
}

variable "spotfire_db_size" {
  # between 5120 MB(5GB) and 16777216 MB(16TB) for General Purpose/Memory Optimized SKUs
  default = "5120"
}

# DB server login credentials
variable "spotfire_db_admin_username" {
  default = "dbadmin"
}

variable "spotfire_db_admin_password" {
  //  default = "d3f4ult!"
}