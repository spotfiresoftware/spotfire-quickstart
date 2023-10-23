output "prefix" {
  value = var.prefix
}

output "appgw_pip" {
  // show only if created
  value = var.create_appgw ? module.appgw[0].appgw_pip : null
}

// jumphost
output "jumphost_pip_addresses" {
  value = module.jumphost.vm_public_ips
}

output "jumphost_ip_addresses" {
  value = module.jumphost.vm_nic_ip_addresses
}

output "jumphost_hostnames" {
  value = module.jumphost.vm_hostnames
}

// sfs
output "sfs_pip_addresses" {
  value = module.sfs.vm_public_ips
}

output "sfs_ip_addresses" {
  value = module.sfs.vm_nic_ip_addresses
}

output "sfs_hostnames" {
  value = module.sfs.vm_hostnames
}

// wp
output "sfwp_ip_addresses" {
  //  value = module.wp.vm_nic_ip_addresses
  value = var.create_sfwp_linux ? module.sfwp.vm_nic_ip_addresses : module.sfwp_windows.vm_nic_ip_addresses
}

output "sfwp_hostnames" {
  //  value = module.wp.vm_hostnames
  value = var.create_sfwp_linux ? module.sfwp.vm_hostnames : module.sfwp_windows.vm_hostnames
}

// db
output "db_server_name" {
  value = var.create_spotfire_db ? module.sfdb[0].db_server.name : var.spotfire_db_name
}

