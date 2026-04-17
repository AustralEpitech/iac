# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "zone" {
  value       = var.zone
  description = "Gcloud Zone"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

# output "kubernetes_cluster_name" {
#   value       = google_container_cluster.primary.name
#   description = "GKE Cluster Name"
# }

# output "kubernetes_cluster_host" {
#   value       = google_container_cluster.primary.endpoint
#   description = "GKE Cluster Host"
# }

output "grafana_ip" {
  value       = google_compute_address.grafana_ip.address
  description = "Static IP address for Grafana"
}
