resource "google_dns_managed_zone" "app_dns_zone" {
  name        = "app-zone"
  dns_name    = "${var.domain_name}."
  description = "DNS zone for application"

  visibility = "public"

  dnssec_config {
    state = "on"
  }
}

resource "google_dns_record_set" "a_record" {
  name         = "${var.domain_name}." # This should be api.iac-epitech.com.
  managed_zone = google_dns_managed_zone.app_dns_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_address.app_ip.address]
}

output "dns_zone_name" {
  description = "Name of the DNS zone"
  value       = google_dns_managed_zone.app_dns_zone.name
}

output "dns_zone_nameservers" {
  description = "Nameservers for your domain (configure these at your registrar)"
  value       = google_dns_managed_zone.app_dns_zone.name_servers
}

output "domain_name" {
  description = "Full domain name (subdomain)"
  value       = var.domain_name
}
