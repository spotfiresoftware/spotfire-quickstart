#----------------------------------------
# Load Balancer
#----------------------------------------

# A ForwardingRule resource specifies which pool of target virtual machines to forward a packet to if it matches the given [IPAddress, IPProtocol, portRange] tuple.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule
resource "google_compute_forwarding_rule" "default" {
  name       = "${var.prefix}-gce-fw-rule"
  target     = google_compute_target_pool.default.id
  port_range = "80-8080"
  //  ports = [ "80", "8080", "8443" ]
}

# Manages a Target Pool = collection of instances used as target of a network load balancer (Forwarding Rule).
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_pool
resource "google_compute_target_pool" "default" {
  name = "${var.prefix}-gce-pool"

  session_affinity = "CLIENT_IP"

  region = var.region

#  instances        = [
#      "europe-west2-a/sandbox-somo-sfs-0",
#      "europe-west2-b/sandbox-somo-sfs-1",
#  ]
  # get instance list dynamically:
  instances = tolist(google_compute_instance.sfs.*.self_link)

  health_checks = [
    google_compute_http_health_check.default.name,
  ]
}

resource "google_compute_http_health_check" "default" {
  name               = "${var.prefix}-login-check"
  request_path       = "/spotfire/login.html"
  port               = 80
  check_interval_sec = 10
  timeout_sec        = 1
}

output "gce_fw_ip" {
  value = google_compute_forwarding_rule.default.ip_address
}
output "lb_instances" {
  value = tolist(google_compute_instance.sfs.*.id)
}
