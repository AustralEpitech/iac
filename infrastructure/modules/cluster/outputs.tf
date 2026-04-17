output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "The IP address of the cluster master."
}

output "cluster_ca_certificate" {
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  description = "The public certificate that is the root of trust for the cluster."
}

output "app_pool_service_account_email" {
  value       = google_service_account.app_pool_nodes.email
  description = "Service account email for application pool nodes"
}

output "cluster_id" {
  value       = google_container_cluster.primary.id
  description = "The cluster ID used to construct node tags"
}
