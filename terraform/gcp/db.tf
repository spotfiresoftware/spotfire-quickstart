
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
//  peer_network = var.wp_vpc_id
//}

# NOTE: This is not longer required. We use create-db to create spotfire_database
#resource "google_sql_database" "database" {
#  name     = "${var.prefix}-db-${var.tss_version}"
#  instance = google_sql_database_instance.master.name
#}

//# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
//# Private instance
//resource "google_compute_network" "private_network" {
//  provider = google-beta
//
//  name = "private-network"
//}
//
//# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
//resource "google_compute_global_address" "private_ip_address" {
//  provider = google-beta
//
//  name          = "${var.prefix}-private-ip"
//  address_type  = "INTERNAL"
//  purpose       = "VPC_PEERING"
//  prefix_length = 16
//  network       = google_compute_network.private_network.id
////  network = module.vpc.network_id
//
//  depends_on = [module.vpc]
//}
//
//resource "google_service_networking_connection" "private_vpc_connection" {
//  provider = google-beta
//
//  network                 = google_compute_network.private_network.id
////  network                 = module.vpc.network_id
//  service                 = "servicenetworking.googleapis.com"
//  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
//}

# https://cloud.google.com/sql/
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
resource "google_sql_database_instance" "master" {
  //  name = var.spotfire_db_name
  name             = "${var.prefix}-spotfire-db-alpha"
  database_version = var.postgresql_db_version
  region           = var.region

  # required to destroy the db
  deletion_protection = false

  //  depends_on = [google_service_networking_connection.private_vpc_connection]
  //  depends_on = [module.vpc.network]

  settings {
    tier            = var.spotfire_db_instance_class
    disk_size       = var.spotfire_db_size # GB
    disk_autoresize = true

    # HA (REGIONAL) or single (ZONAL)
    #availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled = true # "false" prevents to assign a public ip
      require_ssl  = false

      //      private_network = "default"
      //      private_network = "projects/${var.project_id}/global/networks/${module.vpc.network_name}"
      //      private_network = module.vpc.network_id
      //      private_network = google_compute_network.private_network.id
      //      private_network = module.vpc.subnets

      authorized_networks {
        name = "spotfiredb_connect"
        // value = var.static_ip_wp
        value = "0.0.0.0/0"
      }
    }

    user_labels = {
      role = "spotfiredb"
    }
  }
}

resource "google_sql_user" "default" {
  instance = google_sql_database_instance.master.name
  name     = var.spotfire_db_admin_username
  password = var.spotfire_db_admin_password
  #host     = "%" # allows connection from any host, only for troubleshooting
}

output "spotfire_db_name" {
  #value = var.create_spotfire_db ? google_sql_database.database.name : var.spotfire_db_name
  value = var.spotfire_db_name
}

locals {
  spotfire_db_address = var.create_spotfire_db ? google_sql_database_instance.master.public_ip_address : var.spotfire_db_name
}
