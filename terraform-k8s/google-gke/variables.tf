#----------------------------------------
# Resources prefix & tags
#----------------------------------------
variable "prefix" {
  default     = "k8s-codename"
  description = "Prefix for resources"
}

#----------------------------------------
# GCP Location: regions & zones
#----------------------------------------
# https://cloud.google.com/compute/docs/regions-zones
variable "region" {
  default     = "europe-north1"
  description = "Google Cloud region"
}

variable "zone" {
  default     = "europe-north1-a"
  description = "Google Cloud zone"
}
