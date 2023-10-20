#------------------------------------------------------------------------------#
# Basic Spotfire install
#------------------------------------------------------------------------------#

#----------------------------------------
# TLS private key
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "private_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
  algorithm = "ED25519"
}

#resource "local_file" "public_key" {
#  filename        = "${var.ssh_private_key_file}.pub"
#  content         = trimspace(tls_private_key.private_key.public_key_openssh)
#  file_permission = "0400"
#}
#
#resource "local_sensitive_file" "private_key" {
#  filename        = var.ssh_private_key_file
#  content         = tls_private_key.private_key.private_key_pem
#  file_permission = "0400"
#}

# Writes the generated private key to a local file for usage from Ansible
variable "workspace_dir" {
  default = "./terraform.tfstate.d/"
}

#----------------------------------------
# Network
#----------------------------------------
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones
data "google_compute_zones" "available" {
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "static" {
  name = "ipv4-address"
}

variable "gce_ssh_user" {
  default = "spotfire"
}

#----------------------------------------
# Virtual Machines (Linux)
#----------------------------------------

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
resource "google_compute_instance" "jumphost" {
  count = var.jumphost_instances

  name         = "${var.prefix}-jumphost-${count.index}"
  machine_type = var.jumphost_instance_type
  zone         = data.google_compute_zones.available.names[count.index]

  tags = [var.prefix, "jumphost"]

  boot_disk {
    initialize_params {
#      image = "debian-cloud/debian-11"
      image = var.jumphost_vm_os
      size  = 10 # GB
    }
  }

  can_ip_forward = true

  network_interface {
    #network = module.vpc.network_name
    network    = local.network
    #subnetwork = module.vpc.subnets_ids[0]
    subnetwork = element(module.vpc.subnets_ids.*, count.index)

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.ssh_public_key_file)}"
  }

  allow_stopping_for_update = true

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  labels = {
    role = "jumphost"
  }
}

//resource "google_compute_address" "default" {
//  name   = "${lookup(var.instance, "name")}"
//  region = "${lookup(var.instance, "region")}"
//}

resource "google_compute_instance" "tss" {
  count = var.tss_instances

  name         = "${var.prefix}-tss-${count.index}"
  machine_type = var.tss_instance_type
  zone         = element(data.google_compute_zones.available.names, count.index)

  tags = [var.prefix, "tss"]

  boot_disk {
    initialize_params {
      image = var.tss_vm_os
      size  = 10
    }
  }

  network_interface {
    network    = local.network
    subnetwork = element(module.vpc.subnets_ids.*, count.index)
  }
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.ssh_public_key_file)}"
  }

  allow_stopping_for_update = true

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = {
    role = "tss"
  }
}

#----------------------------------------
# Virtual Machines (Windows)
#----------------------------------------
data "template_file" "windows_configure_ssh" {
  template = <<EOF
net user ${var.wp_admin_username} '${var.wp_admin_password}' /add /y
net localgroup administrators ${var.wp_admin_username} /add

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

New-NetFirewallRule -Name sshd -DisplayName 'WinRemoteDesktop (3389)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 3389
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (22)'     -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
EOF
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
# https://cloud.google.com/compute/docs/images/os-details#windows_server
# https://cloud.google.com/compute/docs/instances/startup-scripts/windows
resource "google_compute_instance" "wp" {
  count = var.wp_instances

  name         = "${var.prefix}-wp-${count.index}"
  machine_type = var.wp_instance_type
  zone         = element(data.google_compute_zones.available.names, count.index)

  tags = [var.prefix, "tswp"]

  boot_disk {
    initialize_params {
#      image = "windows-2022"
      image = var.wp_vm_os
      size  = 50 # min for windows-2022
    }
  }

  network_interface {
    network    = local.network
    subnetwork = element(module.vpc.subnets_ids.*, count.index)
  }
  metadata = {
    # https://cloud.google.com/compute/docs/metadata/default-metadata-values
#    enable-windows-ssh = true
    windows-startup-script-ps1 = var.create_wp_linux ? null : data.template_file.windows_configure_ssh.rendered
    ssh-keys = "${var.gce_ssh_user}:${file(var.ssh_public_key_file)}"
  }
#  provisioner "file" {
#    source      = var.ssh_public_key_file
#    destination = "C:/Users/${var.wp_admin_username}/.ssh/id_rsa.pub"
#  }

  allow_stopping_for_update = true

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = {
    role = "tswp"
  }
}

#----------------------------------------
# Firewall rules
#----------------------------------------
resource "google_compute_firewall" "allow-ssh-jumphost" {
  project     = var.project_id
  name        = "${var.prefix}-allow-ssh-jumphost"
  network     = local.network
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "1000-2000"]
  }

  target_tags = ["jumphost"]
}

resource "google_compute_firewall" "allow-all-internal" {
  project     = var.project_id
  name        = "${var.prefix}-allow-all-intenal"
  network     = local.network
  description = "Allows internal traffic"

  allow {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "allow-tss-db" {
  project     = var.project_id
  name        = "${var.prefix}-allow-tss-db"
  network     = local.network
  description = "Allows internal traffic"

  allow {
    protocol = "tcp"
  }
}

#----------------------------------------
# Template files
#----------------------------------------

# Generates the Ansible Config file (credentials)
resource "local_file" "ansible-config-infra" {
  content = templatefile("${path.module}/ansible_config.tmpl", {
    tss_version          = var.tss_version,
    ssh_private_key_file = var.ssh_private_key_file,
    jumphost_user        = var.jumphost_admin_username,
    tss_user             = var.tss_admin_username,
    wp_user              = var.wp_admin_username,
    wp_password          = var.wp_admin_password,
    db_host              = local.spotfire_db_address,
    db_admin_user        = var.spotfire_db_admin_username,
    db_admin_password    = var.spotfire_db_admin_password,
    db_name              = var.spotfire_db_name,
    ui_admin_user        = var.spotfire_ui_admin_username,
    ui_admin_password    = var.spotfire_ui_admin_password
    }
  )
  filename             = "${var.workspace_dir}/${terraform.workspace}/ansible_config/infra.yml"
  file_permission      = "0660"
  directory_permission = "0770"
}