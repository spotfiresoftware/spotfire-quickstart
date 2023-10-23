##################################################################################################################
# OUTPUT Files
##################################################################################################################

# Generates the Ansible Inventory file
resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/ansible_inventory.tmpl", {
    username            = var.jumphost_admin_username,
    jumphost_public_ips = local.jumphost_public_ips,
    jumphost_hostnames  = local.jumphost_hostnames,
    sfs_hostnames       = local.sfs_hostnames,
    sfwp_hostnames        = local.sfwp_hostnames
    }
  )
  filename             = "terraform.tfstate.d/${terraform.workspace}/ansible_config_files/hosts"
  file_permission      = "0660"
  directory_permission = "0770"
}

# Generates the Ansible Inventory file
resource "local_file" "ansible-inventory-yml" {
  content = templatefile("${path.module}/ansible_inventory.yml.tmpl", {
    username            = var.jumphost_admin_username,
    jumphost_public_ips = local.jumphost_public_ips,
    jumphost_hostnames  = local.jumphost_hostnames,
    sfs_public_ips      = var.sfs_public_ips,
    sfs_hostnames       = local.sfs_hostnames,
    sfwp_hostnames        = local.sfwp_hostnames
    }
  )
  filename             = "terraform.tfstate.d/${terraform.workspace}/ansible_config_files/hosts.yml"
  file_permission      = "0660"
  directory_permission = "0770"
}
