// DATABASE //
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "Region for resources"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "app-db"
}

variable "private_vpc_connection" {
  description = "Gcp Network connection"
  type        = any
}

variable "vpc" {
  description = "VPC value"
  type        = any
}

variable "db_user" {
  type        = string
  description = "Database user name"
  sensitive   = true
}

variable "db_pwd" {
  type        = string
  description = "Database user name"
  sensitive   = true
}

variable "deletion_protection" {
  description = "Deletion protection state"
  type        = bool
}

variable "app_pool_service_account_email" {
  type        = string
  description = "Service account email for application pool nodes (for Cloud SQL Proxy access)"
  default     = ""
}
