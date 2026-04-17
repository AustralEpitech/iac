resource "google_project_service" "monitoring" {
  project = var.project_id
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# Static IP for Grafana LoadBalancer
resource "google_compute_address" "grafana_ip" {
  name   = "grafana-static-ip"
  region = var.region
}

# GCP Service Account for Grafana
resource "google_service_account" "grafana" {
  account_id   = "grafana-sa"
  display_name = "Grafana Service Account"
  project      = var.project_id
}

# IAM: Grant monitoring viewer role to Grafana SA
resource "google_project_iam_member" "grafana_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.grafana.email}"
}

# Workload Identity binding: Allow K8s SA to impersonate GCP SA
resource "google_service_account_iam_member" "grafana_workload_identity" {
  service_account_id = google_service_account.grafana.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[monitoring/grafana]"
}

# Grafana deployment via Helm
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Kubernetes Service Account for Grafana with Workload Identity annotation
resource "kubernetes_service_account_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.grafana.email
    }
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = "7.3.0"

  # Use the Kubernetes Service Account with Workload Identity
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account_v1.grafana.metadata[0].name
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.loadBalancerIP"
    value = google_compute_address.grafana_ip.address
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = "10Gi"
  }

  # Configure datasource using Google Cloud Monitoring with PromQL support
  values = [
    yamlencode({
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              # Use Google Cloud Monitoring datasource (stackdriver)
              # which supports PromQL queries via Managed Prometheus
              name      = "Google Cloud Managed Prometheus"
              type      = "stackdriver"
              access    = "proxy"
              isDefault = true
              jsonData = {
                # Authentication type: GCE uses Workload Identity automatically
                authenticationType = "gce"
                defaultProject     = "${var.project_id}"
              }
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    google_project_service.monitoring,
    google_service_account_iam_member.grafana_workload_identity,
    kubernetes_service_account_v1.grafana
  ]
}
