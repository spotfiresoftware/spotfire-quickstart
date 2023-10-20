##################################################################################################################
# OUTPUT Files
##################################################################################################################

# Generates the Ansible Inventory file
resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/ansible_inventory.tmpl", {
    username            = var.jumphost_admin_username,
    jumphost_public_ips = local.jumphost_public_ips,
    jumphost_hostnames  = local.jumphost_hostnames,
    tss_hostnames       = local.tss_hostnames,
    wp_hostnames        = local.wp_hostnames
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
    tss_public_ips      = var.tss_public_ips,
    tss_hostnames       = local.tss_hostnames,
    wp_hostnames        = local.wp_hostnames
    }
  )
  filename             = "terraform.tfstate.d/${terraform.workspace}/ansible_config_files/hosts.yml"
  file_permission      = "0660"
  directory_permission = "0770"
}
