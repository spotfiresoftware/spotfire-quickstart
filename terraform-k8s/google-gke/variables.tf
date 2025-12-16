#----------------------------------------
# Resources prefix & tags
#----------------------------------------
variable "project_id" {
  default = "my-project-id"
  description = "My project name"
}

variable "prefix" {
  default     = "k8s-codename"
  description = "Prefix for resources"
}

#----------------------------------------
# GCP Location: regions & zones
#----------------------------------------
# https://cloud.google.com/compute/docs/regions-zones
variable "region" {
  default     = "europe-north2" # Stockholm, Sweden, Europe
  description = "Google Cloud region"
}

variable "zone" {
  default     = "europe-north2-a" # Stockholm, Sweden, Europe
  description = "Google Cloud zone"
}

variable "labels" {
  type = map(string)

  default = {
    # specific tags
    description   = "spotfire-quickstart"
    app           = "spotfire"
    app_version   = "14.6.0"
    environment   = "dev"
    infra_version = "0.5"
  }
}