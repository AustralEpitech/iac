# ============================================================================
# EARLY SECRETS - Created first, used by modules
# ============================================================================

resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# JWT Secret
resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "jwt-secret-id"

  replication {
    auto {}
  }
  labels = {
    managed_by = "terraform"
    app        = "backend"
  }
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "jwt_secret" {
  secret      = google_secret_manager_secret.jwt_secret.id
  secret_data = var.jwt_secret
}

# ============================================================================
# LATE SECRETS - Created after modules
# ============================================================================

# Database Connection Secret (depends on database module)
resource "google_secret_manager_secret" "db_connection" {
  secret_id = "${var.project_id}-db-connection"

  replication {
    auto {}
  }
  labels = {
    managed_by = "terraform"
    source     = "module-output"
    app        = "backend"
  }
  depends_on = [google_project_service.secretmanager, module.database]
}

resource "google_secret_manager_secret_version" "db_connection" {
  secret = google_secret_manager_secret.db_connection.id
  secret_data = jsonencode({
    host            = module.database.db_instance.private_ip_address
    port            = 5432
    database        = module.database.google_sql_database.name
    username        = var.db_user
    password        = var.db_pwd
    connection_name = module.database.db_instance.connection_name
  })
  depends_on = [module.database]
}
