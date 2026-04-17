# Reference the artifact registries created by the bootstrap project
# These are data sources, not resources - we're querying existing infrastructure

data "google_artifact_registry_repository" "runners" {
  location      = var.region
  repository_id = "github-runners"
}

data "google_artifact_registry_repository" "app" {
  location      = var.region
  repository_id = "app-images"
}

# Output the registry URLs for use in other resources
output "artifact_registry_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${data.google_artifact_registry_repository.runners.repository_id}"
  description = "Artifact Registry URL for pushing images"
}

output "runner_image_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${data.google_artifact_registry_repository.runners.repository_id}/runner:latest"
  description = "Full image URL for the custom runner"
}

output "app_image_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${data.google_artifact_registry_repository.app.repository_id}/${var.app_name}:latest"
  description = "Full image URL for the application"
}
