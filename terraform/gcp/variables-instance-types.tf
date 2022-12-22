#----------------------------------------
# VM instance types
#----------------------------------------

# https://cloud.google.com/compute/docs/machine-types
variable "jumphost_instance_type" {
  default = "e2-micro"
}
variable "tss_instance_type" {
  default = "e2-standard-2"
}
variable "wp_instance_type" {
  default = "e2-standard-2"
}
