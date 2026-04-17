output "app_service_name" {
  value       = kubernetes_service_v1.app.metadata[0].name
  description = "Name of the Kubernetes service"
}

output "app_namespace" {
  value       = kubernetes_namespace_v1.app.metadata[0].name
  description = "Kubernetes namespace for the application"
}

output "ingress_name" {
  value       = kubernetes_ingress_v1.app.metadata[0].name
  description = "Name of the Kubernetes Ingress"
}
