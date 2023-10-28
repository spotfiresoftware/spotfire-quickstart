variable "admin_address_prefixes" {
  # Recommended to use more strict than /9 mask
  description = "CIDR or source IP range allowed for environment administration"
  default     = ["43.21.0.0/16"]
}

variable "gke_username" {
  default     = ""
  description = "GKE username"
}

variable "gke_password" {
  default     = ""
  description = "GKE password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "Number of GKE nodes (per region)"
}

variable "gke_machine_type" {
  default     = "n1-standard-1"
  description = "Type of machine for k8s GKE nodes"
}

variable "gke_cluster_version" {
  default = "1.28"
  description = "GKE Kubernetes minimum version"
}

# GKE cluster
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
#
# NOTE: It is recommended that node pools be created and managed as separate resources as in the example above.
# This allows node pools to be added and removed without recreating the cluster.
# Node pools defined directly in the google_container_cluster resource cannot be removed without re-creating the cluster.

resource "google_container_cluster" "primary" {
  name     = "${var.prefix}-gke"
  location = var.region
  # NOTE: If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master.
  # If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well
  # see: https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = false
  initial_node_count       = 1
  deletion_protection      = false # set to true if not testing

#  min_master_version = var.gke_cluster_version

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "services-range"
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range.1.range_name
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.admin_address_prefixes[0]
    }
  }
}

# GKE Managed Node Pool
#
# NOTE: In this example the node pool is in the same terraform file.
# For being able to modify the node pool without recreating the cluster, the node pools must be managed separately.
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    #service_account = google_service_account.default.email
    # NOTE: oauth cloud-platform scope is required for access to pull private images from the Container Registry within the same project
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = var.gke_machine_type
    tags         = ["gke-node", "${var.prefix}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}


# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

