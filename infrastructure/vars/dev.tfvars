// GCP
project_id = "iac-dev-494208"
region     = "europe-west1"
zone       = "europe-west1-b"

// VPC
vpc_name   = "iac-dev-vpc"
cidr_block = "10.0.0.0/16"

// Database (non-secret)
db_name = "appdb"

// Cluster
cluster_name         = "iac-dev-cluster"
runner_pool_name     = "runner-pool"
runner_pool_sa       = "gke-runner-sa"
runner_pool_sa_roles = [
  "roles/artifactregistry.reader",
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
]
deletion_protection = false
app_name            = "flask-app"
app_pool_sa         = "gke-app-sa"
app_pool_sa_roles = [
  "roles/artifactregistry.reader",
  "roles/cloudsql.client",
  "roles/secretmanager.secretAccessor",
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
]
