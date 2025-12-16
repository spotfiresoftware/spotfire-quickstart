#----------------------------------------
# VPC
#----------------------------------------
# https://registry.terraform.io/modules/terraform-google-modules/network/google/latest
module "vpc" {
  source  = "terraform-google-modules/network/google"

  project_id   = var.project_id
  network_name = "${var.prefix}-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${var.prefix}-subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    },
    {
      subnet_name           = "${var.prefix}-subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet has a description"
    },
    {
      subnet_name               = "${var.prefix}-subnet-03"
      subnet_ip                 = "10.10.30.0/24"
      subnet_region             = var.region
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
    }
  ]

  secondary_ranges = {
    subnet-01 = [
      {
        range_name    = "${var.prefix}-subnet-01-secondary-01"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]

    subnet-02 = []
  }

  routes = [
    {
      name              = "${var.prefix}-egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}

locals {
  network = module.vpc.network_id
}

# https://registry.terraform.io/modules/terraform-google-modules/cloud-router/google/latest
# https://github.com/terraform-google-modules/terraform-google-cloud-router
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project_id

  name = "${var.prefix}-router"
  network = local.network
  region  = var.region

  nats = [{
    name = "${var.prefix}-nat-gateway"
  }]
}
