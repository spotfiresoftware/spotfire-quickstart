# Spotfire setup using Terraform Azure provider
#   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
#   https://github.com/terraform-providers/terraform-provider-azurerm

# Setup common infrastructure
module "base" {
  source   = "./modules/base"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags
}

# Setup networking
module "networking" {
  source   = "./modules/networking"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # dependencies
  resource_group_name = module.base.rg_name

  # specific
  inbound_ports_to_allow          = var.open_tcp_ports
  admin_address_prefix            = var.admin_address_prefix
  vnet_address_space              = var.vnet_address_space
  public_subnet_address_prefixes  = var.public_subnet_address_prefixes
  private_subnet_address_prefixes = var.private_subnet_address_prefixes
}

# Setup storage
module "storage" {
  source   = "./modules/storage"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # dependencies
  resource_group_name = module.base.rg_name
  subnet_id           = module.networking.private_subnet_id
}

# Setup certificates
module "certificates" {
  source   = "./modules/certificates"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # dependencies
  resource_group_name = module.base.rg_name
}

# Setup bastion host
module "bastion" {
  // conditional module execution
  count = var.create_bastion ? 1 : 0

  source   = "./modules/bastion"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # dependencies
  resource_group_name = module.base.rg_name
  //  availability_set_id = module.base.availability_set_id
  //  subnet_id           = module.networking.subnet_id
  vnet_name = module.networking.vnet_name

  # specific
  bastion_subnet_address_prefixes = var.bastion_subnet_address_prefixes
}

# Setup tssdb
module "tssdb" {
  // conditional module execution
  count = var.create_spotfire_db ? 1 : 0

  source   = "./modules/tssdb"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # dependencies
  resource_group_name = module.base.rg_name
  //  availability_set_id = module.base.availability_set_id
  subnet_id = module.networking.private_subnet_id

  # specific
  postgresql_db_version      = var.postgresql_db_version
  spotfire_db_size           = var.spotfire_db_size
  spotfire_db_admin_username = var.spotfire_db_admin_username
  spotfire_db_admin_password = var.spotfire_db_admin_password
}

# Setup jumphost
module "jumphost" {
  source   = "./modules/vm_linux"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # specific
  role = "jumphost"

  vm_instances = var.jumphost_instances
  vm_size      = var.jumphost_vm_size

  os_publisher = var.os_publisher
  os_distro    = var.os_distro
  os_sku       = var.os_sku
  os_version   = var.os_version

  vm_admin_username   = var.jumphost_admin_username
  vm_admin_password   = var.jumphost_admin_password
  ssh_public_key_file = var.ssh_public_key_file

  create_public_ip = true

  # dependencies
  resource_group_name = module.base.rg_name
  availability_set_id = module.base.availability_set_id
  subnet_id           = module.networking.public_subnet_id
}

# Setup tss
module "tss" {
  source   = "./modules/vm_linux"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # specific
  role = "tss"

  vm_instances = var.tss_instances
  vm_size      = var.tss_vm_size

  os_publisher = var.os_publisher
  os_distro    = var.os_distro
  os_sku       = var.os_sku
  os_version   = var.os_version

  vm_admin_username   = var.tss_admin_username
  vm_admin_password   = var.tss_admin_password
  ssh_public_key_file = var.ssh_public_key_file

  create_public_ip = var.tss_create_public_ip

  # dependencies
  resource_group_name = module.base.rg_name
  availability_set_id = module.base.availability_set_id
  subnet_id           = module.networking.private_subnet_id
}

# Setup wp
module "wp" {
  // conditional module execution
  //  count = var.create_wp_linux ? 1 : 0

  source   = "./modules/vm_linux"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # specific
  role = "wp"

  //  vm_instances      = var.wp_instances
  vm_instances = var.create_wp_linux ? var.wp_instances : 0
  vm_size      = var.wp_vm_size

  os_publisher = var.wp_os_publisher
  os_distro    = var.wp_os_offer
  os_sku       = var.wp_os_sku
  os_version   = var.wp_os_version

  vm_admin_username   = var.wp_admin_username
  vm_admin_password   = var.wp_admin_password
  ssh_public_key_file = var.ssh_public_key_file

  create_public_ip = false

  # dependencies
  resource_group_name = module.base.rg_name
  availability_set_id = module.base.availability_set_id
  subnet_id           = module.networking.private_subnet_id
}

# Setup wp
module "wp_windows" {
  // conditional module execution
  //  count = var.create_wp_linux ? 0 : 1

  source   = "./modules/vm_windows"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # specific
  role = "wp"

  //  vm_instances = var.wp_instances
  vm_instances = var.create_wp_linux ? 0 : var.wp_instances
  vm_size      = var.wp_vm_size

  os_publisher = var.wp_os_publisher
  os_offer     = var.wp_os_offer
  os_sku       = var.wp_os_sku
  os_version   = var.wp_os_version

  vm_admin_username = var.wp_admin_username
  vm_admin_password = var.wp_admin_password
  //  ssh_public_key_file  = var.ssh_public_key_file

  # dependencies
  resource_group_name = module.base.rg_name
  availability_set_id = module.base.availability_set_id
  subnet_id           = module.networking.private_subnet_id

  key_vault_id   = module.certificates.key_vault_id
  cert_secret_id = module.certificates.cert_secret_id
  key_vault_key  = module.certificates.key_vault_key

  storage_account   = module.storage.storage_account
  storage_share     = module.storage.storage_share
  storage_container = module.storage.storage_container
  //  win_script_ssh_setup = module.storage.win_script_ssh_setup
}

module "appgw" {
  // conditional module execution
  count = var.create_appgw ? 1 : 0

  source   = "./modules/appgw"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # dependencies
  resource_group_name = module.base.rg_name

  # specific
  vnet_name           = module.networking.vnet_name
  vm_nic_ip_addresses = module.tss.vm_nic_ip_addresses
}

# Generate output files
module "output_files" {
  source = "./modules/output_files"

  # dependencies
  resource_group_name = module.base.rg_name

  # specific
  workspace_dir = "./terraform.tfstate.d/"

  ssh_private_key_file = var.ssh_private_key_file

  jumphost_public_ips = module.jumphost.vm_public_ips
  jumphost_hostnames  = module.jumphost.vm_hostnames

  tss_public_ips = module.tss.vm_public_ips
  tss_hostnames  = module.tss.vm_hostnames

  //  wp_hostnames = module.wp.vm_hostnames
  wp_hostnames = var.create_wp_linux ? module.wp.vm_hostnames : module.wp_windows.vm_hostnames

  // vm credentials
  jumphost_admin_username = var.jumphost_admin_username
  jumphost_admin_password = var.jumphost_admin_password
  tss_admin_username      = var.tss_admin_username
  tss_admin_password      = var.tss_admin_password
  wp_admin_username       = var.wp_admin_username
  wp_admin_password       = var.wp_admin_password

  // db credentials
  spotfire_db_admin_username = var.spotfire_db_admin_username
  spotfire_db_admin_password = var.spotfire_db_admin_password

  // ui credentials
  spotfire_ui_admin_username = var.spotfire_ui_admin_username
  spotfire_ui_admin_password = var.spotfire_ui_admin_password

  // conditional output (must indicate the first and only item from the count list)
  spotfire_db_server_name = var.create_spotfire_db ? module.tssdb[0].db_server.name : var.spotfire_db_server_name
  spotfire_db_name        = var.create_spotfire_db ? module.tssdb[0].db_name : var.spotfire_db_name
}
