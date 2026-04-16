
resource "google_project_service" "artifact_api" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "runners" {
  location      = var.region
  repository_id = "github-runners"
  description   = "Docker repository for GitHub Actions custom runner images"
  format        = "DOCKER"

  labels = {
    managed_by = "terraform"
    purpose    = "ci-cd"
  }

  depends_on = [google_project_service.artifact_api]
}

resource "google_artifact_registry_repository" "app" {
  location      = var.region
  repository_id = "app-images"
  description   = "Docker repository for application images"
  format        = "DOCKER"

  labels = {
    managed_by = "terraform"
    purpose    = "application"
  }

  depends_on = [google_project_service.artifact_api]
}

# Output the registry URL
output "artifact_registry_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.runners.repository_id}"
  description = "Artifact Registry URL for pushing images"
}

output "runner_image_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.runners.repository_id}/runner:latest"
  description = "Full image URL for the custom runner"
}

output "app_image_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}/${var.app_name}:latest"
  description = "Full image URL for the application"
}
