resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  network    = var.vpc_name
  subnetwork = var.subnet_name

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = var.deletion_protection

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = ""
    services_secondary_range_name = ""
  }

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Google Managed Prometheus
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
}
