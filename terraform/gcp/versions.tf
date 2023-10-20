terraform {
  # lock version up to 1.5.x, to avoid any possible impact due new Terraform license
  # https://www.hashicorp.com/license-faq
  required_version = "< 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }
}
