variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "app_name" {
  type        = string
  description = "Name of the application"
  default     = "flask-app"
}

variable "app_namespace" {
  type        = string
  description = "Kubernetes namespace for the application"
  default     = "app"
}

variable "app_image" {
  type        = string
  description = "Docker image for the application"
}

variable "replicas" {
  type        = number
  description = "Number of application replicas"
  default     = 1
}

# Database configuration
variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_user" {
  type        = string
  description = "Database user"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "db_connection_name" {
  type        = string
  description = "Cloud SQL connection name"
}

# Secrets
variable "jwt_secret" {
  type        = string
  description = "JWT secret for authentication"
  sensitive   = true
}

# Load Balancer & Ingress
variable "static_ip_name" {
  type        = string
  description = "Name of the static IP for the load balancer"
}

variable "ssl_cert_name" {
  type        = string
  description = "Name of the managed SSL certificate"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the application"
}
