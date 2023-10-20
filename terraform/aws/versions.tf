terraform {
  # lock version up to 1.5.x, to avoid any possible impact due new Terraform license
  # https://www.hashicorp.com/license-faq
  required_version = "< 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">=2.2.0"
    }
  }
}

