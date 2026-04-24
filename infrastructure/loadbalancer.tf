resource "google_compute_global_address" "app_ip" {
  name        = "app-static-ip"
  description = "Static IP address for Task Manager load balancer"

  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

output "static_ip_address" {
  description = "The static IP address reserved for the load balancer"
  value       = google_compute_global_address.app_ip.address
}

output "static_ip_name" {
  description = "Name of the static IP (used in Ingress annotation)"
  value       = google_compute_global_address.app_ip.name
}
