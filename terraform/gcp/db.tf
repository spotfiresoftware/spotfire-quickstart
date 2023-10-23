
//resource "google_compute_network" "sql_vpc" {
//  name                    = "sql-vpc"
//  auto_create_subnetworks = false
//}
//
//output "sql_vpc_id" {
//  value = google_compute_network.sql_vpc.id
//}
//
//resource "google_compute_subnetwork" "db_subnet1" {
//  name          = "subnet1"
//  ip_cidr_range = "10.0.1.0/24"
//  region        = "asia-southeast1"
//  network       = google_compute_network.sql_vpc.id
//  private_ip_google_access = true
//}
//
//resource "google_compute_network_peering" "peering2" {
//  depends_on =[
//    google_compute_network.sql_vpc
//  ]
//  name         = "peering1"
//  network      = google_compute_network.sql_vpc.id
//  peer_network = var.sfwp_vpc_id
//}

//# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
//# Private instance
//resource "google_compute_network" "private_network" {
//  provider = google-beta
//
//  name = "private-network"
//}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.prefix}-private-ip"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 16
  network       = local.network

  depends_on = [module.vpc]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = local.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

locals {
  db_private_ip = google_compute_global_address.private_ip_address.address
}

# https://cloud.google.com/sql/
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
resource "google_sql_database_instance" "master" {
  //  name = var.spotfire_db_name
  name             = "${var.prefix}-spotfire-db"
  database_version = var.postgresql_db_version
  region           = var.region

  # required to destroy the db
  deletion_protection = false         # Terraform level
#  deletion_protection_enabled = false # GCP level

  depends_on = [google_service_networking_connection.private_vpc_connection]
  //  depends_on = [module.vpc.network]

  settings {
    tier            = var.spotfire_db_instance_class
    disk_size       = var.spotfire_db_size # GB
    disk_autoresize = true

    # HA (REGIONAL) or single (ZONAL)
    #availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled = false # "false" prevents to assign a public ip
      require_ssl  = false

      private_network = local.network
      //enable_private_path_for_google_cloud_services = true
#      authorized_networks {
#        name = "spotfiredb_connect"
#        value = "0.0.0.0/0"
#      }
    }

    user_labels = {
      role = "spotfiredb"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user
resource "google_sql_user" "default" {
  instance = google_sql_database_instance.master.name
  name     = var.spotfire_db_admin_username
  password = var.spotfire_db_admin_password

  deletion_policy = "ABANDON"
  #host     = "%" # allows connection from any host, only for troubleshooting
}

# NOTE: This is not longer required. We can just use create-db to create spotfire_database.
#resource "google_sql_database" "database" {
#  name     = "${var.prefix}-db-${var.spotfire_version}"
#  instance = google_sql_database_instance.master.name
#  depends_on = [google_sql_database_instance.master, google_sql_user.default]
#}

output "spotfire_db_name" {
  #value = var.create_spotfire_db ? google_sql_database.database.name : var.spotfire_db_name
  value = var.spotfire_db_name
}

locals {
  #spotfire_db_address = var.create_spotfire_db ? google_sql_database_instance.master.public_ip_address : var.spotfire_db_name
  spotfire_db_address = var.create_spotfire_db ? google_sql_database_instance.master.private_ip_address : var.spotfire_db_name
}
