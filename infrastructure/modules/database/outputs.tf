output "db_instance" {
  value       = google_sql_database_instance.database_instance
  description = "Database instance name"
}

output "google_sql_database" {
  value       = google_sql_database.database
  description = "Google SQL database"
}

output "database_instance_connection_name" {
  value       = google_sql_database_instance.database_instance.connection_name
  description = "Connection name for Cloud SQL (for Cloud SQL Proxy)"
}

output "database_name" {
  value       = google_sql_database.database.name
  description = "Name of the database"
}

output "database_user" {
  value       = google_sql_user.database_user.name
  description = "Database user name"
}

output "database_password" {
  value       = google_sql_user.database_user.password
  description = "Database user password"
  sensitive   = true
}
