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

variable "availability_set_id" {
  default = ""
}

# networking
variable "subnet_id" {
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
  default = "Standard_DS1_v2"
}

# VM Operating System
variable "os_publisher" {
  default = "Debian"
}
variable "os_offer" {
  default = "debian-12"
}
variable "os_sku" {
  default = "12"
}
variable "os_version" {
  default = "0.20251112.2294"
}

# VM login credentials
variable "vm_admin_username" {
  # WARN: cannot be admin/root in Azure
  default = "spotfire"
}
variable "vm_admin_password" {
  //  default = "d3f4ult!"
}
variable "ssh_public_key_file" {
  default = "~/.ssh/id_rsa.pub"
}
variable "create_public_ip" {
  default = false
}
