#----------------------------------------
# Azure account
#----------------------------------------

# credentials
variable subscription_id {
  description = "Azure Subscription ID"
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
    app_version   = "14.6.0"
    environment   = "dev"
    infra_version = "0.5"
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
# Azure location and region
#----------------------------------------
variable "location" {
  default = "northeurope"
}
variable "region" {
  default = "norwayeast"
}

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

#variable "admin_open_tcp_ports" {
#  description = "Open ports for remote access"
#  type        = list(string)
#  default     = [22, 8080, 80, 443]
#}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  default     = "10.0.0.0/8"
}

variable "public_subnet_address_prefixes" {
  description = "Azure Application Gateway's SubNetwork address space"
  default     = ["10.0.0.0/24"]
  //  default = [cidrsubnet(var.vnet_address_space,30,1)]
}

variable "private_subnet_address_prefixes" {
  description = "Spotfire VMs' Virtual Network address space"
  default     = ["10.0.1.0/24"]
  //  default = [cidrsubnet(var.vnet_address_space,8,2)]
}

variable "bastion_subnet_address_prefixes" {
  description = "Azure Bastion VMs' Virtual Network address space"
  default     = ["10.0.2.0/24"]
  //  default = [cidrsubnet(var.vnet_address_space,30,2)]
}

variable "appgw_subnet_address_prefixes" {
  description = "Azure Application Gateway's SubNetwork address space"
  default     = ["10.1.0.0/16"]
}

variable "db_subnet_address_prefixes" {
  description = "Azure Database SubNetwork address space"
  default     = ["10.0.5.0/24"]
}


#----------------------------------------
# Conditional resources creation
#----------------------------------------
variable "create_spotfire_db" {
  description = "Create Azure Database for PostgreSQL service for usage as Spotfire database"
  default     = true
}

variable "create_appgw" {
  description = "Create Azure Application Gateway for HTTP access to Spotfire Server instances (recommended if using Spotfire Server cluster)"
  default     = true
}

variable "create_sfs_public_ip" {
  description = "Create Public IP for direct access to Spotfire Server instances (only for testing)"
  default     = false
}

# NOTE: See documentation for differences when running Web Player on Linux
variable "create_sfwp_linux" {
  description = "Use Linux for Web Player services"
  default     = true
}

variable "create_bastion" {
  description = "Create Bastion host for easier management of Windows VMs (not required)"
  default     = false
}

variable "create_storage" {
  description = "Create Storage (only required for saving Windows init scripts)"
  default     = false
}

#----------------------------------------
# Spotfire Database (sfdb)
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server
# https://docs.microsoft.com/en-us/azure/postgresql/

variable "postgresql_db_version" {
  description = "PostgreSQL data server version"
  # https://docs.microsoft.com/en-us/azure/postgresql/concepts-supported-versions
  # https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-supported-versions
  default = "17"
}

variable "spotfire_db_instance_class" {
  description = "Spotfire database instance class"
  # Name of the pricing tier and compute configuration. Follow the convention {pricing tier}{compute generation}{vCores}
  default = "B_Standard_B2ms"
}

variable "spotfire_db_size" {
  description = "Spotfire database size for Postgres flexible server: one of [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]"
  default = "32768"
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

variable "spotfire_db_server_name" {
  description = "Spotfire database server name"
  default     = "spotfiredb-server"
}
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

# ssh key file
variable "ssh_public_key_file" {
  description = "Spotfire VM SSH public key file location (local)"
  default     = "~/.ssh/id_rsa_azure.pub"
}

variable "ssh_private_key_file" {
  description = "Spotfire VM SSH private key file location (local)"
  default     = "~/.ssh/id_rsa_azure"
}

#----------------------------------------
# VM Operating System
#----------------------------------------

# VM Operating System
variable "os_publisher" {
  description = "Spotfire VM operating system publisher"
  default     = "Debian"
}
variable "os_offer" {
  description = "Spotfire VM operating system distribution"
  default     = "debian-12"
}
variable "os_sku" {
  description = "Spotfire VM operating system SKU"
  default     = "12"
}
variable "os_version" {
  description = "Spotfire VM operating system version"
  default     = "0.20251112.2294"
}

#----------------------------------------
# jumphost
#----------------------------------------
# VM login credentials
variable "jumphost_admin_username" {
  description = "Spotfire VM admin username"
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed" Target="adminPassword"
variable "jumphost_admin_password" {
  description = "Spotfire VM admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# Spotfire Server (sfs)
#----------------------------------------
# VM login credentials
variable "sfs_admin_username" {
  description = "Spotfire Server VM admin username"
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed" Target="adminPassword"
variable "sfs_admin_password" {
  description = "Spotfire Server VM admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# Web Player (wp)
#----------------------------------------
# VM Operating System
variable "sfwp_os_publisher" {
  description = "Spotfire Web Player VM operating system publisher"
  default     = "MicrosoftWindowsServer"
}
variable "sfwp_os_offer" {
  description = "Spotfire Web Player VM operating system offer"
  default     = "WindowsServer"
}
variable "sfwp_os_sku" {
  description = "Spotfire Web Player VM operating system SKU"
  default     = "2019-Datacenter"
}
variable "sfwp_os_version" {
  description = "Spotfire Web Player VM operating system version"
  default     = "latest"
}

# VM login credentials
variable "sfwp_admin_username" {
  description = "Spotfire Web Player VM admin username"
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
# NOTE: The supplied password must be between 8-123 characters long
# and must satisfy at least 3 of password complexity requirements from the following:
#    1) Contains an uppercase character
#    2) Contains a lowercase character
#    3) Contains a numeric digit
#    4) Contains a special character
#    5) Control characters are not allowed" Target="adminPassword"
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

#----------------------------------------
# Spotfire Server version
#----------------------------------------
variable "spotfire_version" {
  description = "Spotfire version"
  default     = "14.6.0"
}