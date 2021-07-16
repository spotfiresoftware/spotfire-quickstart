# common
variable "prefix" {
  default = "spotfire"
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
variable "availability_set_id" {
  default = ""
}

# networking
variable "subnet_id" {
  default = ""
}

# certificates
variable "key_vault_id" {
  default = ""
}
variable "cert_secret_id" {
  default = ""
}
variable "key_vault_key" {
  default = ""
}

#----------------------------------------
# specific (this)
variable "vm_instances" {
  description = "Number of instances"
  default     = 1
}

variable "role" {
  default = "none"
}
# VM size
variable "vm_size" {
  default = "Standard_A2_v2"
}

# VM Operating System
variable "os_publisher" {
  default = "MicrosoftWindowsServer"
}
variable "os_offer" {
  default = "WindowsServer"
}
variable "os_sku" {
  default = "2019-Datacenter"
}
variable "os_version" {
  default = "latest"
}

# VM login credentials
variable "vm_admin_username" {
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
variable "vm_admin_password" {
  //  default = "d3f4ult!"
}
//variable "ssh_pub_key_file" {
//  default = "~/.ssh/id_rsa.pub"
//}
//variable "script-config-ssh" {
//  default = "scripts/ConfigureSSH.ps1"
//}

variable "storage_account" {
  default = ""
}
variable "storage_share" {
  default = ""
}
variable "storage_container" {
  default = ""
}