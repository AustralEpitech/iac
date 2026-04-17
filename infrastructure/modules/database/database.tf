resource "random_id" "db_postgree" {
  byte_length = 4
}

resource "google_sql_database_instance" "database_instance" {
  name             = "${var.db_name}-${random_id.db_postgree.hex}"
  database_version = "POSTGRES_15"
  region           = var.region

  depends_on          = [var.private_vpc_connection]
  deletion_protection = var.deletion_protection

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"


    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 2

      backup_retention_settings {
        retained_backups = 2
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc.id
    }
  }
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.database_instance.name
}

# Create database user
resource "google_sql_user" "database_user" {
  name     = var.db_user
  instance = google_sql_database_instance.database_instance.name
  password = var.db_pwd
}

