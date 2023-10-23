output "prefix" {
  value = var.prefix
}

# jumphost
output "jumphost_pip_addresses" {
  value = aws_instance.jumphost.*.public_ip
}

output "sfs_ip_addresses" {
  value = aws_instance.sfs.*.private_ip
}

output "jumphost_hostnames" {
  value = aws_instance.sfs.*.host_id
}

# db
output "db_address" {
  value = var.create_spotfire_db ? aws_db_instance.this[0].address : var.spotfire_db_name
}
