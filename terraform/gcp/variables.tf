#----------------------------------------
# Google Project ID
#----------------------------------------
variable "project_id" {
  description = "project id"
}

#----------------------------------------
# Conditional resources creation
#----------------------------------------
variable "create_spotfire_db" {
  description = "Create AWS RDS for PostgreSQL service for usage as Spotfire database"
  default     = true
}

#variable "create_lb" {
#  description = "Create Load Balancer for HTTP access to Spotfire Server instances (recommended if using Spotfire Server cluster)"
#  default     = true
#}
#
#variable "create_sfs_public_ip" {
#  description = "Create Public IP for direct access to Spotfire Server instances (only for testing)"
#  default     = false
#}
#
# NOTE: See documentation for differences when running Web Player on Linux
variable "create_sfwp_linux" {
  description = "Use Linux for Web Player services"
  default     = true
}

#----------------------------------------
# Resources prefix & tags
#----------------------------------------
variable "tags" {
  type = map(string)

  default = {
    # specific tags
    description   = "Spotfire Quickstart: Basic install"
    app           = "Spotfire"
    app_version   = "14.0.0"
    environment   = "dev"
    infra_version = "0.4"
  }
}

variable "prefix" {
  default     = "sandbox-codename"
  description = "Prefix for resources"
}

#variable "environment" {
#  default = "dev"
#}

#----------------------------------------
# Google region
#----------------------------------------
# location
variable "region" {
  default     = "europe-north1"
  description = "Google Cloud region"
}

#variable "zone" {
#  default     = "europe-north1-a"
#  description = "Google Cloud zone"
#}

#----------------------------------------
# Networking
#----------------------------------------
variable "admin_address_prefixes" {
  # Recommended to use more strict than /9 mask
  description = "CIDR or source IP range allowed for environment administration"
  default     = ["43.21.0.0/16"]
}

variable "web_address_prefixes" {
  description = "CIDR or source IP range allowed for remote access for Spotfire application"
  default     = ["43.0.0.0/8"]
}

#----------------------------------------
# Spotfire Server (sfs)
#----------------------------------------
variable "spotfire_version" {
  description = "Spotfire Server version"
  default     = "14.0.0"
}

#----------------------------------------
# Spotfire Database (sfdb)
#----------------------------------------
# https://cloud.google.com/sql/
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
variable "postgresql_db_version" {
  description = "PostgreSQL data server version"
  default     = "POSTGRES_15"
}

variable "spotfire_db_instance_class" {
  description = "Spotfire database instance class"
  default     = "db-f1-micro"
}

variable "spotfire_db_size" {
  description = "Spotfire database size in gibibytes (GiB)"
  # Must be an integer from 1 to ...
  default = "10"
}

# DB server login credentials
variable "spotfire_db_admin_username" {
  description = "Spotfire database admin username"
  default     = "dbadmin"
}
variable "spotfire_db_admin_password" {
  description = "Spotfire database admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#variable "spotfire_db_server_name" {
#  description = "Spotfire database server name"
#  default     = "spotfiredb-server"
#}
variable "spotfire_db_name" {
  description = "Spotfire database name"
  default     = "spotfiredb"
}

#----------------------------------------
# Spotfire Admin UI login credentials
#----------------------------------------
variable "spotfire_ui_admin_username" {
  description = "Spotfire web UI admin username"
  default     = "admin"
}
variable "spotfire_ui_admin_password" {
  description = "Spotfire web UI admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# generic VM (Linux)
#----------------------------------------

variable "key_name" {
  default = "ec2key"
  type    = string
}

# ssh key file
variable "ssh_public_key_file" {
  description = "Spotfire VM SSH public key file location (local)"
  default     = "~/.ssh/id_rsa_gcp.pub"
}

variable "ssh_private_key_file" {
  description = "Spotfire VM SSH private key file location (local)"
  default     = "~/.ssh/id_rsa_gcp"
}

#----------------------------------------
# VM Operating System
#----------------------------------------

# https://cloud.google.com/compute/docs/images/os-details
variable "jumphost_vm_os" {
  default = "debian-cloud/debian-12"
}
variable "sfs_vm_os" {
  default = "debian-cloud/debian-12"
}
variable "sfwp_vm_os" {
#  default = "windows-2022"
  default = "debian-cloud/debian-12"
}

#----------------------------------------
# jumphost
#----------------------------------------
# VM login credentials
variable "jumphost_admin_username" {
  description = "Jumphost Server VM admin username"
  default     = "spotfire"
}

#----------------------------------------
# Spotfire Server (sfs)
#----------------------------------------
# VM login credentials
variable "sfs_admin_username" {
  description = "Spotfire Server VM admin username"
  default     = "spotfire"
}

#----------------------------------------
# Spotfire Web Player (sfwp)
#----------------------------------------
# VM login credentials
variable "sfwp_admin_username" {
  description = "Spotfire Web Player VM admin username"
  default     = "spotfire"
}
variable "sfwp_admin_password" {
  description = "Spotfire Web Player VM admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# VM instances number
#----------------------------------------
variable "jumphost_instances" {
  description = "Number of jumphost instances"
  default     = 1
}
variable "sfs_instances" {
  description = "Number of Spotfire Server instances"
  default     = 2
}
variable "sfwp_instances" {
  description = "Number of Spotfire Web Player instances"
  default     = 2
}