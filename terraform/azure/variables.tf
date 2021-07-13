#----------------------------------------
# Conditional resources creation
#----------------------------------------
variable "create_spotfire_db" {
  description = "Create Azure Database for PostgreSQL service for usage as Spotfire database"
  default     = true
}

variable "create_appgw" {
  description = "Create Azure Application Gateway for HTTP access to TIBCO Spotfire Server instances (recommended if using Spotfire Server cluster)"
  default     = true
}

variable "tss_create_public_ip" {
  description = "Create Public IP for direct access to TIBCO Spotfire Server instances (only for testing)"
  default     = false
}

variable "create_bastion" {
  description = "Create Bastion host for easier management of Windows VMs (not required)"
  default     = false
}

# WARN: WP on Linux is not currently supported, just for testing future support
variable "create_wp_linux" {
  description = "Use Linux for Web Player services (experimental, the default is Windows)"
  default     = false
}

#----------------------------------------
# Resources prefix
#----------------------------------------
variable "tags" {
  type = map(string)

  default = {
    # specific tags
    name          = "Spotfire basic install"
    app           = "Spotfire"
    app_version   = "11.4"
    environment   = "dev"
    infra_version = "0.1"
  }
}
variable "prefix" {
  default = "sandbox"
}

#----------------------------------------
# Azure location and region
#----------------------------------------
variable "location" {
  //  default = "North Europe"
  default = "northeurope"
}
variable "region" {
  default = "norwayeast"
}

#----------------------------------------
# Networking
#----------------------------------------
variable "admin_address_prefix" {
  description = "CIDR or source IP range allowed for remote access"
  default     = "43.21.0.0/16"
}

variable "open_tcp_ports" {
  description = "Open ports for remote access"
  type        = list(string)
  default     = [22, 8080, 80, 443]
}

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

variable "agw_subnet_address_prefixes" {
  description = "Azure Application Gateway's SubNetwork address space"
  default     = ["10.0.3.0/24"]
  //  default = [cidrsubnet(var.vnet_address_space,30,1)]
}

#----------------------------------------
# Spotfire Database (tssdb)
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server
# https://docs.microsoft.com/en-us/rest/api/postgresql/servers/create#StorageProfile

variable "postgresql_db_version" {
  description = "PostgreSQL data server version"
  default     = "11"
}

variable "spotfire_db_size" {
  description = "Spotfire database size"
  # between 5120 MB(5GB) and 16777216 MB(16TB) for General Purpose/Memory Optimized SKUs
  default = "5120"
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

# Admin UI login credentials
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
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_file" {
  description = "Spotfire VM SSH private key file location (local)"
  default     = "~/.ssh/id_rsa"
}

# VM Operating System
variable "os_publisher" {
  description = "Spotfire VM operating system publisher"
  default     = "OpenLogic"
}
variable "os_distro" {
  description = "Spotfire VM operating system distribution"
  default     = "Centos"
}
variable "os_sku" {
  description = "Spotfire VM operating system SKU"
  default     = "8_2"
}
variable "os_version" {
  description = "Spotfire VM operating system version"
  default     = "8.2.2020111800"
}

#----------------------------------------
# jumphost
#----------------------------------------
# VM instances number
variable "jumphost_instances" {
  description = "Number of jumphost instances"
  default     = 1
}
# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
variable "jumphost_vm_size" {
  description = "Jumphost VM size"
  default     = "Standard_A1_v2"
}
# VM login credentials
variable "jumphost_admin_username" {
  description = "Spotfire VM admin username"
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
// NOTE: The supplied password must be between 8-123 characters long
// and must satisfy at least 3 of password complexity requirements from the following:
//    1) Contains an uppercase character
//    2) Contains a lowercase character
//    3) Contains a numeric digit
//    4) Contains a special character
//    5) Control characters are not allowed" Target="adminPassword"
variable "jumphost_admin_password" {
  description = "Spotfire VM admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# Spotfire Server (tss)
#----------------------------------------
# VM instances number
variable "tss_instances" {
  description = "Number of TIBCO Spotfire Server instances"
  default     = 2
}

# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
variable "tss_vm_size" {
  description = "TIBCO Spotfire Server VM size"
  //  default = "Standard_A1_v2" // 1cores, 2GiB, 10 GB SSD, 250Mbps
  default = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
}

# VM login credentials
variable "tss_admin_username" {
  description = "TIBCO Spotfire Server VM admin username"
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
// NOTE: The supplied password must be between 8-123 characters long
// and must satisfy at least 3 of password complexity requirements from the following:
//    1) Contains an uppercase character
//    2) Contains a lowercase character
//    3) Contains a numeric digit
//    4) Contains a special character
//    5) Control characters are not allowed" Target="adminPassword"
variable "tss_admin_password" {
  description = "TIBCO Spotfire Server VM admin password"
  default     = "d3f4ult!"
  sensitive   = true
}

#----------------------------------------
# Web Player (wp)
#----------------------------------------
# VM instances number
variable "wp_instances" {
  description = "Number of TIBCO Spotfire Web Player instances"
  default     = 2
}

# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
variable "wp_vm_size" {
  description = "TIBCO Spotfire Web Player VM size"
  //  default = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
  default = "Standard_A4_v2" // 4cores, 8GiB, 40 GB SSD, 1000Mbps
}

# VM Operating System
variable "wp_os_publisher" {
  description = "TIBCO Spotfire Web Player VM operating system publisher"
  default     = "MicrosoftWindowsServer"
}
variable "wp_os_offer" {
  description = "TIBCO Spotfire Web Player VM operating system offer"
  default     = "WindowsServer"
}
variable "wp_os_sku" {
  description = "TIBCO Spotfire Web Player VM operating system SKU"
  default     = "2019-Datacenter"
}
variable "wp_os_version" {
  description = "TIBCO Spotfire Web Player VM operating system version"
  default     = "latest"
}

# VM login credentials
variable "wp_admin_username" {
  description = "TIBCO Spotfire Web Player VM admin username"
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
// NOTE: The supplied password must be between 8-123 characters long
// and must satisfy at least 3 of password complexity requirements from the following:
//    1) Contains an uppercase character
//    2) Contains a lowercase character
//    3) Contains a numeric digit
//    4) Contains a special character
//    5) Control characters are not allowed" Target="adminPassword"
variable "wp_admin_password" {
  description = "TIBCO Spotfire Web Player VM admin password"
  default     = "d3f4ult!"
  sensitive   = true
}
