#----------------------------------------
# Conditional resources creation
#----------------------------------------
variable "create_spotfire_db" {
  default = false
}

variable "create_appgw" {
  default = true
}

variable "tss_create_public_ip" {
  default = false
}

variable "create_bastion" {
  description = "Create Bastion host or not. Boolean."
  default = false
}

# WARN: WP on Linux is not currently supported, just for testing future support
variable "create_wp_linux" {
  description = "Use Linux for Web Player services"
  default = false
}

#----------------------------------------
# Resources prefix
#----------------------------------------
variable "tags" {
  type        = map(string)

  default = {
//    name                  = "Spotfire basic install"
//    tier                  = "infra"
    app                   = "Spotfire"
    app_version           = "11.x"
//    environment           = "sandbox"
//    infra_version         = "0.1"
//    owner                 = "mdiez@tibco.com"
    "Business Unit"       = "Products & Technology"
    "Cost Center"         = "63615"
    "Department"          = "Spotfire Development Platform"
    "Classification"      = "Non-Production"
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
variable "source_address_prefix" {
  description = "CIDR or source IP range allowed for remote access"
  default = "85.0.0.0/8"
}

variable "open_tcp_ports" {
  type    = list(string)
  default = [22, 8080, 80, 443]
}

variable "vnet_address_space" {
  description = "Specify Application Gateway's SubNetwork address space"
  default = "10.0.0.0/8"
}

variable "public_subnet_address_prefixes" {
  description = "Specify Application Gateway's SubNetwork address space"
  default = ["10.0.0.0/24"]
//  default = [cidrsubnet(var.vnet_address_space,30,1)]
}

variable "private_subnet_address_prefixes" {
  description = "Specify application's VirtualNetwork address space"
  default = ["10.0.1.0/24"]
//  default = [cidrsubnet(var.vnet_address_space,8,2)]
}

variable "bastion_subnet_address_prefixes" {
  description = "Specify application's VirtualNetwork address space"
  default = ["10.0.2.0/24"]
  //  default = [cidrsubnet(var.vnet_address_space,30,2)]
}

variable "agw_subnet_address_prefixes" {
  description = "Specify Application Gateway's SubNetwork address space"
  default = ["10.0.3.0/24"]
  //  default = [cidrsubnet(var.vnet_address_space,30,1)]
}

#----------------------------------------
# Spotfire Database (tssdb)
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server
# https://docs.microsoft.com/en-us/rest/api/postgresql/servers/create#StorageProfile

variable "postgresql_db_version" {
  default = "11"
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
  default = "d3f4ult!"
  sensitive = true
}

variable "spotfire_db_server_name" {
  default = "spotfire-dbserver"
}
variable "spotfire_db_name" {
  default = "spotfire-db"
}

# Admin UI login credentials
variable "spotfire_ui_admin_username" {
  default = "admin"
}
variable "spotfire_ui_admin_password" {
  default = "d3f4ult!"
  sensitive = true
}

#----------------------------------------
# generic VM (Linux)
#----------------------------------------
# VM login credentials
variable "vm_admin_username" {
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
variable "vm_admin_password" {
  default = "d3f4ult!"
  sensitive = true
}

# ssh key file
variable "ssh_pub_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

# VM Operating System
variable "os_publisher" {
  default = "OpenLogic"
}
variable "os_distro" {
  default = "Centos"
}
variable "os_sku" {
  default = "8_2"
}
variable "os_version" {
  default = "8.2.2020111800"
}

#----------------------------------------
# jumphost
#----------------------------------------
# VM size
# https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
variable "jumphost_vm_size" {
  default = "Standard_A1_v2"
}
variable "jumphost_instances" {
  description = "Number of jumphost instances"
  default     = 1
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
//  default = "Standard_A1_v2" // 1cores, 2GiB, 10 GB SSD, 250Mbps
  default = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
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
//  default = "Standard_A2_v2" // 2cores, 4GiB, 20 GB SSD, 500Mbps
  default = "Standard_A4_v2" // 4cores, 8GiB, 40 GB SSD, 1000Mbps
}

# VM Operating System
variable "wp_os_publisher" {
  default = "MicrosoftWindowsServer"
}
variable "wp_os_offer" {
  default = "WindowsServer"
}
variable "wp_os_sku" {
  default = "2019-Datacenter"
}
variable "wp_os_version" {
  default = "latest"
}

# VM login credentials
variable "wp_admin_username" {
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
  default = "d3f4ult!"
  sensitive = true
}
