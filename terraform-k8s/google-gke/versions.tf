terraform {
  # Lock Terraform version to 1.5.x, to avoid any possible impact due new Terraform license
  # https://www.hashicorp.com/license-faq
  # Set the corresponding version if you own a Terraform license or,
  # alternatively, configure OpenTofu (a fork of Terraform) https://opentofu.org/
  required_version = "< 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=7.10.0"
    }
  }
}
