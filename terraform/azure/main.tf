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
  jumphost_public_ips = module.jumphost.vm_public_ips

  # specific
  admin_address_prefixes          = var.admin_address_prefixes
  web_address_prefixes            = var.web_address_prefixes
  vnet_address_space              = var.vnet_address_space
  public_subnet_address_prefixes  = var.public_subnet_address_prefixes
  private_subnet_address_prefixes = var.private_subnet_address_prefixes
  appgw_subnet_address_prefixes   = var.appgw_subnet_address_prefixes
}

# Setup storage
module "storage" {
  count    = var.create_storage ? 1 : 0
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
  resource_group_name    = module.base.rg_name
  admin_address_prefixes = var.admin_address_prefixes
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
  vnet_name           = module.networking.vnet_name

  # specific
  bastion_subnet_address_prefixes = var.bastion_subnet_address_prefixes
}

# Setup sfdb
module "sfdb" {
  // conditional module execution
  count = var.create_spotfire_db ? 1 : 0

  source   = "./modules/postgres_flexible_db"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # dependencies
  resource_group_name        = module.base.rg_name
  //  availability_set_id = module.base.availability_set_id
  virtual_network_id         = module.networking.vnet_id
  virtual_network_name       = module.networking.vnet_name

  # specific
  db_subnet_address_prefixes = var.db_subnet_address_prefixes
  postgresql_db_version      = var.postgresql_db_version
  spotfire_db_size           = var.spotfire_db_size
  spotfire_db_instance_class = var.spotfire_db_instance_class
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
  vm_size      = var.jumphost_size

  os_publisher = var.os_publisher
  os_offer     = var.os_offer
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

# Setup sfs
module "sfs" {
  source   = "./modules/vm_linux"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # specific
  role = "sfs"

  vm_instances = var.sfs_instances
  vm_size      = lookup(var.sfs_instance_types, var.sfs_size)

  os_publisher = var.os_publisher
  os_offer     = var.os_offer
  os_sku       = var.os_sku
  os_version   = var.os_version

  vm_admin_username   = var.sfs_admin_username
  vm_admin_password   = var.sfs_admin_password
  ssh_public_key_file = var.ssh_public_key_file

  create_public_ip = var.create_sfs_public_ip

  # dependencies
  resource_group_name = module.base.rg_name
  availability_set_id = module.base.availability_set_id
  subnet_id           = module.networking.private_subnet_id
}

# Setup wp
module "sfwp" {
  // conditional module execution
  //  count = var.create_sfwp_linux ? 1 : 0

  source   = "./modules/vm_linux"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # specific
  role = "sfwp"

  //  vm_instances      = var.sfwp_instances
  vm_instances = var.create_sfwp_linux ? var.sfwp_instances : 0
  vm_size      = lookup(var.sfwp_instance_types, var.sfwp_size)

  os_publisher = var.sfwp_os_publisher
  os_offer     = var.sfwp_os_offer
  os_sku       = var.sfwp_os_sku
  os_version   = var.sfwp_os_version

  vm_admin_username   = var.sfwp_admin_username
  vm_admin_password   = var.sfwp_admin_password
  ssh_public_key_file = var.ssh_public_key_file

  create_public_ip = false

  # dependencies
  resource_group_name = module.base.rg_name
  availability_set_id = module.base.availability_set_id
  subnet_id           = module.networking.private_subnet_id
}

# Setup wp
module "sfwp_windows" {
  // conditional module execution
  count = var.create_sfwp_linux ? 0 : 1

  source   = "./modules/vm_windows"
  location = var.location
  prefix   = var.prefix
  tags     = var.tags

  # specific
  role = "wp"

  //  vm_instances = var.sfwp_instances
  vm_instances = var.create_sfwp_linux ? 0 : var.sfwp_instances
  vm_size      = lookup(var.sfwp_instance_types, var.sfwp_size)

  os_publisher = var.sfwp_os_publisher
  os_offer     = var.sfwp_os_offer
  os_sku       = var.sfwp_os_sku
  os_version   = var.sfwp_os_version

  vm_admin_username = var.sfwp_admin_username
  vm_admin_password = var.sfwp_admin_password
  //  ssh_public_key_file  = var.ssh_public_key_file

  # dependencies
  resource_group_name = module.base.rg_name
  availability_set_id = module.base.availability_set_id
  subnet_id           = module.networking.private_subnet_id

  key_vault_id   = module.certificates.key_vault_id
  cert_secret_id = module.certificates.cert_secret_id
  key_vault_key  = module.certificates.key_vault_key

  # storage is only required for Windows init scripts, not required for Linux services
  storage_account   = var.create_sfwp_linux ? 0 : module.storage.storage_account
  storage_share     = var.create_sfwp_linux ? 0 : module.storage.storage_share
  storage_container = var.create_sfwp_linux ? 0 : module.storage.storage_container
  //  win_script_ssh_setup = module.storage.win_script_ssh_setup
}

module "appgw" {
  // conditional module execution
  count = var.create_appgw ? 1 : 0

  source                        = "./modules/appgw"
  location                      = var.location
  prefix                        = var.prefix
  tags                          = var.tags
  appgw_subnet_address_prefixes = var.appgw_subnet_address_prefixes

  # dependencies
  resource_group_name = module.base.rg_name

  # specific
  vnet_name           = module.networking.vnet_name
  vm_nic_ip_addresses = module.sfs.vm_nic_ip_addresses
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

  sfs_public_ips = module.sfs.vm_public_ips
  sfs_hostnames  = module.sfs.vm_hostnames

  //  sfwp_hostnames = module.wp.vm_hostnames
  sfwp_hostnames = var.create_sfwp_linux ? module.sfwp.vm_hostnames : module.sfwp_windows.vm_hostnames

  // vm credentials
  jumphost_admin_username = var.jumphost_admin_username
  jumphost_admin_password = var.jumphost_admin_password
  sfs_admin_username      = var.sfs_admin_username
  sfs_admin_password      = var.sfs_admin_password
  sfwp_admin_username     = var.sfwp_admin_username
  sfwp_admin_password     = var.sfwp_admin_password

  // db credentials
  spotfire_db_admin_username = var.spotfire_db_admin_username
  spotfire_db_admin_password = var.spotfire_db_admin_password

  // ui credentials
  spotfire_ui_admin_username = var.spotfire_ui_admin_username
  spotfire_ui_admin_password = var.spotfire_ui_admin_password

  // conditional output (must indicate the first and only item from the count list)
  spotfire_db_server_name = var.create_spotfire_db ? module.sfdb[0].db_server.name : var.spotfire_db_server_name
  #spotfire_db_name        = var.create_spotfire_db ? module.sfdb[0].db_name : var.spotfire_db_name
  spotfire_db_name        = var.spotfire_db_name

  spotfire_version  = var.spotfire_version
}
