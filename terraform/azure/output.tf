//output "bastion_pip" {
//  value = module.bastion.bastion_pip
//}

output "appgw_pip" {
  // show only if created
  value = var.create_appgw ? module.appgw[0].appgw_pip : null
}

//output "prefix" {
//  value = var.prefix
//}

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

// tss
output "tss_pip_addresses" {
  value = module.tss.vm_public_ips
}

output "tss_ip_addresses" {
  value = module.tss.vm_nic_ip_addresses
}

output "tss_hostnames" {
  value = module.tss.vm_hostnames
}

// wp
output "wp_ip_addresses" {
  //  value = module.wp.vm_nic_ip_addresses
  value = var.create_wp_linux ? module.wp.vm_nic_ip_addresses : module.wp_windows.vm_nic_ip_addresses
}

output "wp_hostnames" {
  //  value = module.wp.vm_hostnames
  value = var.create_wp_linux ? module.wp.vm_hostnames : module.wp_windows.vm_hostnames
}

// db
output "db_server_name" {
  value = var.create_spotfire_db ? module.tssdb[0].db_server.name : var.spotfire_db_name
}