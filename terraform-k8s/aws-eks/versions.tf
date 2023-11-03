terraform {
  # lock version up to 1.5.x, to avoid any possible impact due new Terraform license
  # https://www.hashicorp.com/license-faq
  required_version = "< 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.23.0"
    }
  }
}

