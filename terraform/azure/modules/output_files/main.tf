#----------------------------------------
# Output files
#----------------------------------------

# Generates the dynamic Ansible Inventory file
resource "local_file" "ansible-inventory-azurerm" {
  content = templatefile("${path.module}/host_groups_azure_rm.yml.tmpl", {
    resource_group_name = var.resource_group_name
    }
  )
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/host_groups_azure_rm.yml"
  file_permission      = "0770"
  directory_permission = "0770"
}

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
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/hosts"
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
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/hosts.yml"
  file_permission      = "0660"
  directory_permission = "0770"
}

# Generates the Ansible Config file (credentials)
resource "local_file" "ansible-config-infra" {
  content = templatefile("${path.module}/ansible_config.tmpl", {
    ssh_priv_key_file = var.ssh_private_key_file
    jumphost_user     = var.jumphost_admin_username,
    jumphost_password = var.jumphost_admin_password,
    tss_user          = var.tss_admin_username,
    tss_password      = var.tss_admin_password,
    wp_user           = var.wp_admin_username,
    wp_password       = var.wp_admin_password,
    db_admin_user     = var.spotfire_db_admin_username,
    db_admin_password = var.spotfire_db_admin_password,
    db_server         = var.spotfire_db_server_name,
    db_name           = var.spotfire_db_name,
    ui_admin_user     = var.spotfire_ui_admin_username,
    ui_admin_password = var.spotfire_ui_admin_password
    }
  )
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/infra.yml"
  file_permission      = "0660"
  directory_permission = "0770"
}
