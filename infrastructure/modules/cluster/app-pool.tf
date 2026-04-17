# Service Account for Application Pool Nodes
resource "google_service_account" "app_pool_nodes" {
  account_id   = var.app_pool_sa
  display_name = "Application Pool Nodes Service Account"
  description  = "Service account for application pool nodes to access Cloud SQL and other GCP services"
}

resource "google_project_iam_member" "app_pool_sa_roles" {
  for_each = toset(var.app_pool_sa_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.app_pool_nodes.email}"
}

resource "google_container_node_pool" "application_pool" {
  name     = "application-pool"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  autoscaling {
    min_node_count  = 1
    max_node_count  = 10
    location_policy = "BALANCED"
  }

  node_config {
    preemptible     = true
    machine_type    = "n1-standard-1"
    service_account = google_service_account.app_pool_nodes.email

    labels = {
      workload-type = "application"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GCE_METADATA"
    }
  }

  depends_on = [google_container_cluster.primary]
}
