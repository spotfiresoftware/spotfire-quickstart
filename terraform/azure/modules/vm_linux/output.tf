output "vm_public_ips" {
  value = azurerm_public_ip.this.*.ip_address
}

output "vm_nic_ids" {
  value = azurerm_network_interface.this.*.id
}

output "vm_nic_ip_addresses" {
  value = azurerm_network_interface.this.*.private_ip_address
}

output "vm_hostnames" {
  value = azurerm_linux_virtual_machine.this.*.name
}