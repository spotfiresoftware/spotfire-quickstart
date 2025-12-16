// global
//variable "resource_group_name" { default = "" }
variable "resource_group_name" {
  description = "Specify the resource group name"
}

variable "workspace_dir" { default = "./terraform.tfstate.d" }

# Generates the Ansible Config file (credentials)
variable "spotfire_version" {
  default = "14.6.0"
}

// credentials
variable "ssh_private_key_file" {}
variable "jumphost_admin_username" {}
variable "jumphost_admin_password" {}
variable "sfs_admin_username" {}
variable "sfs_admin_password" {}
variable "sfwp_admin_username" {}
variable "sfwp_admin_password" {}
variable "spotfire_db_admin_username" {}
variable "spotfire_db_admin_password" {}
variable "spotfire_db_server_name" {}
variable "spotfire_db_name" {}
variable "spotfire_ui_admin_username" {}
variable "spotfire_ui_admin_password" {}

variable "sfs_public_ips" { default = "" }

variable "sfs_hostnames" {
  description = "List of NICs for the Spotfire Server VMs instances"
}
variable "sfwp_hostnames" {
  description = "List of NICs for the Spotfire Web Player VM instances"
}

variable "jumphost_public_ips" { default = "" }
variable "jumphost_hostnames" { default = "" }

locals {
  //  public-ips-jumpboxes-linux   = var.public-ips-jumpboxes-linux[*].ip_address
  jumphost_public_ips = [for key, value in var.jumphost_public_ips : value]
  jumphost_hostnames  = [for key, value in var.jumphost_hostnames : value]
  //  sfs_public_ips      = var.sfs_public_ips[*].ip_address
  sfs_hostnames = [for key, value in var.sfs_hostnames : value]
  sfwp_hostnames  = [for key, value in var.sfwp_hostnames : value]
}
