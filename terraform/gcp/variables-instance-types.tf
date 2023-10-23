#----------------------------------------
# VM instance types
#----------------------------------------

# https://cloud.google.com/compute/docs/machine-types
# https://cloud.google.com/compute/docs/machine-resource
variable "jumphost_instance_type" {
  default = "e2-micro"
}
variable "sfs_instance_type" {
  default = "e2-standard-2"
}
variable "sfwp_instance_type" {
  default = "e2-standard-2"
}
