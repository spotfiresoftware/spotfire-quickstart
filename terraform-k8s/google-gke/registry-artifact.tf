# Google Cloud Artifact Registry
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository
resource "google_artifact_registry_repository" "default" {
  location = var.region
#  repository_id = "${var.prefix}-repository"
  repository_id = "spotfire-quickstart"
  description   = "Spotfire container images repository"
  format        = "DOCKER"
}

# See: https://github.com/hashicorp/terraform-provider-google/issues/11355
output "google_artifact_registry_repository" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${ google_artifact_registry_repository.default.repository_id}"
  description = "Google Artifact Registry"
}