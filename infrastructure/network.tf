resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.vpc_name}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.vpc_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_project_service" "service_networking" {
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.service_networking]
}
resource "google_compute_firewall" "allow_gke_master_to_nodes" {
  name = "allow-gke-master-to-nodes"

  project = var.project_id

  network = google_compute_network.vpc.name

  description = "Allow GKE master to communicate with nodes for kubectl logs/exec"

  allow {
    protocol = "tcp"
    ports    = ["10250", "443", "8443"]
  }

  source_ranges = ["10.128.0.0/9", "172.16.0.0/28"]

  target_tags = ["gke-${var.cluster_name}-node"]
}

resource "google_compute_router" "nat_router" {
  name   = "nat-router"
  region = var.region

  network = google_compute_network.vpc.name

  description = "Router for Cloud NAT to enable internet access for pods"
}
