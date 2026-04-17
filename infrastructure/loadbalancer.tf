
resource "google_compute_global_address" "app_ip" {
  name        = "app-static-ip"
  description = "Static IP address for Task Manager load balancer"

  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_managed_ssl_certificate" "app_cert" {
  name    = "app-ssl-cert"
  project = var.project_id

  managed {
    domains = ["api.${var.domain_name}"]
  }

}

output "static_ip_address" {
  description = "The static IP address reserved for the load balancer"
  value       = google_compute_global_address.app_ip.address
}

output "static_ip_name" {
  description = "Name of the static IP (used in Ingress annotation)"
  value       = google_compute_global_address.app_ip.name
}

output "ssl_cert_name" {
  description = "Name of the managed SSL certificate (used in Ingress annotation)"
  value       = google_compute_managed_ssl_certificate.app_cert.name
}
