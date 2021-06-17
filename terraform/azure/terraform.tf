terraform {
  required_version = ">= 0.14.00"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.60.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.1.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">=3.1.0"
    }
  }
}