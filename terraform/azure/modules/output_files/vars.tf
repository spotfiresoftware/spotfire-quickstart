// global
//variable "resource_group_name" { default = "" }
variable "resource_group_name" {
  description = "Specify the resource group name"
}

variable "workspace_dir" { default = "./terraform.tfstate.d" }

# Generates the Ansible Config file (credentials)
variable "tss_version" {
  default = "12.0.0"
}

// credentials
variable "ssh_private_key_file" {}
variable "jumphost_admin_username" {}
variable "jumphost_admin_password" {}
variable "tss_admin_username" {}
variable "tss_admin_password" {}
variable "wp_admin_username" {}
variable "wp_admin_password" {}
variable "spotfire_db_admin_username" {}
variable "spotfire_db_admin_password" {}
variable "spotfire_db_server_name" {}
variable "spotfire_db_name" {}
variable "spotfire_ui_admin_username" {}
variable "spotfire_ui_admin_password" {}

variable "tss_public_ips" { default = "" }

variable "tss_hostnames" {
  description = "List of NICs for the TIBCO Spotfire Server VMs instances"
}
variable "wp_hostnames" {
  description = "List of NICs for the TIBCO Spotfire Web Player VM instances"
}

variable "jumphost_public_ips" { default = "" }
variable "jumphost_hostnames" { default = "" }

locals {
  //  public-ips-jumpboxes-linux   = var.public-ips-jumpboxes-linux[*].ip_address
  jumphost_public_ips = [for key, value in var.jumphost_public_ips : value]
  jumphost_hostnames  = [for key, value in var.jumphost_hostnames : value]
  //  tss_public_ips      = var.tss_public_ips[*].ip_address
  tss_hostnames = [for key, value in var.tss_hostnames : value]
  wp_hostnames  = [for key, value in var.wp_hostnames : value]
}
