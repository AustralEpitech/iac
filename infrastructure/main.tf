resource "google_project_service" "container_api" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "networking_api" {
  project            = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns_api" {
  project            = var.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

module "cluster" {
  source = "./modules/cluster"

  cluster_name         = var.cluster_name
  runner_pool_name     = var.runner_pool_name
  project_id           = var.project_id
  region               = var.region
  zone                 = var.zone
  runner_pool_sa       = var.runner_pool_sa
  runner_pool_sa_roles = var.runner_pool_sa_roles
  app_pool_sa          = var.app_pool_sa
  app_pool_sa_roles    = var.app_pool_sa_roles
  deletion_protection  = var.deletion_protection
  subnet_name          = google_compute_subnetwork.subnet.name
  vpc_name             = google_compute_network.vpc.name

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.networking_api,
    google_project_service.container_api,
    google_secret_manager_secret_version.jwt_secret,
    google_secret_manager_secret_version.ssl_cert,
    google_secret_manager_secret_version.ssl_key,
    google_secret_manager_secret_version.github_repo_token
  ]
}

module "runners" {
  source = "./modules/runners"

  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  github_config_url = var.github_config_url
  arc_runner_name   = var.arc_runner_name
  runner_image_url  = "${var.region}-docker.pkg.dev/${var.project_id}/${data.google_artifact_registry_repository.runners.repository_id}/runner:latest"

  depends_on = [
    module.cluster,
    data.google_artifact_registry_repository.runners,
    google_secret_manager_secret_version.github_repo_token
  ]
}

module "database" {
  source = "./modules/database"

  project_id = var.project_id
  db_name    = var.db_name
  db_pwd     = var.db_pwd
  db_user    = var.db_user
  region     = var.region

  private_vpc_connection         = google_service_networking_connection.private_vpc_connection
  vpc                            = google_compute_network.vpc
  deletion_protection            = var.deletion_protection
  app_pool_service_account_email = module.cluster.app_pool_service_account_email

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.networking_api,
    module.cluster,
    google_secret_manager_secret_version.jwt_secret,
    google_secret_manager_secret_version.ssl_cert,
    google_secret_manager_secret_version.ssl_key
  ]
}

module "app" {
  source = "./modules/app"

  project_id = var.project_id

  app_image = "${var.region}-docker.pkg.dev/${var.project_id}/${data.google_artifact_registry_repository.app.repository_id}/flask-app:latest"

  db_name            = module.database.database_name
  db_user            = module.database.database_user
  db_password        = module.database.database_password
  db_connection_name = module.database.database_instance_connection_name

  jwt_secret = var.jwt_secret

  static_ip_name = google_compute_global_address.app_ip.name
  ssl_cert_name  = "app-cert"
  domain_name    = var.domain_name

  depends_on = [
    module.cluster,
    module.database,
    data.google_artifact_registry_repository.app,
    google_compute_global_address.app_ip,
    google_secret_manager_secret_version.jwt_secret,
    google_secret_manager_secret_version.ssl_cert,
    google_secret_manager_secret_version.ssl_key,
    google_secret_manager_secret_version.db_connection
  ]
}
