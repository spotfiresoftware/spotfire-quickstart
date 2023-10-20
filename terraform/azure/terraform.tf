terraform {
  # lock version up to 1.5.x, to avoid any possible impact due new Terraform license
  # https://www.hashicorp.com/license-faq
  required_version = "< 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.1.0"
    }
  }
}
