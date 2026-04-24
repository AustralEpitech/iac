resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace
  }
}

# ConfigMap for non-sensitive configuration
resource "kubernetes_config_map_v1" "app" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    DB_NAME            = var.db_name
    DB_USER            = var.db_user
    DB_CONNECTION_NAME = var.db_connection_name
    DB_HOST            = "127.0.0.1"
  }
}

# Secret for sensitive data
resource "kubernetes_secret_v1" "app" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    # Terraform encodes these to Base64 automatically; do not use base64encode()
    JWT_SECRET = var.jwt_secret
    DB_PASS    = var.db_password
  }

  type = "Opaque"
}

# Deployment
resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  wait_for_rollout = false

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        node_selector = {
          workload-type = "application"
        }


        # Cloud SQL Proxy sidecar container
        container {
          name  = "cloud-sql-proxy"
          image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.6.0"
          args = [
            "--port=5432",
            "--address=0.0.0.0",
            "--private-ip",
            var.db_connection_name
          ]
          security_context {
            run_as_non_root = true
          }
          resources {
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }
        }

        # Application container
        container {
          name = var.app_name
          # IMPORTANT: Ensure this image is built with --platform linux/amd64
          image = var.app_image

          port {
            container_port = 8080
            name           = "http"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.app.metadata[0].name
            }
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.app.metadata[0].name
                key  = "JWT_SECRET"
              }
            }
          }

          env {
            name = "DB_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.app.metadata[0].name
                key  = "DB_PASS"
              }
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          startup_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 30 # Allow up to 2.5 minutes for startup
          }
        }
      }
    }
  }
}

# Service - NodePort for GCE Ingress compatibility
resource "kubernetes_service_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels = {
      app = var.app_name
    }
    annotations = {
      # Enable container-native load balancing for better performance
      "cloud.google.com/neg" = jsonencode({ ingress = true })
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
      name        = "http"
    }

    type = "NodePort"
  }
}

# ==============================================================================
# INGRESS - HTTP only (no domain, no SSL)
# Routes external traffic to the app via GCE L7 Load Balancer
# ==============================================================================
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
      "kubernetes.io/ingress.global-static-ip-name" = var.static_ip_name
      "kubernetes.io/ingress.allow-http"            = "true"
    }
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service_v1.app.metadata[0].name
        port {
          number = 80
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = "${var.app_name}-hpa"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    min_replicas = 2
    max_replicas = 10

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.app.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }
  }
}
