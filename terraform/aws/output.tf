
// jumphost
output "jumphost_pip_addresses" {
  value = aws_instance.jumphost.*.public_ip
}

output "jumphost_ip_addresses" {
  value = aws_instance.tss.*.private_ip
}

output "jumphost_hostnames" {
  value = aws_instance.tss.*.host_id
}

// db
output "db_address" {
  //  value = var.create_spotfire_db ? module.tssdb[0].db_server.name : var.spotfire_db_name
  value = var.create_spotfire_db ? aws_db_instance.this[0].address : var.spotfire_db_name
}
