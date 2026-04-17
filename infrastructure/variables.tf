
// GCP Variable
variable "project_id" {
  type        = string
  description = "Cloud project ID"
}

variable "region" {
  type        = string
  description = "Region for resources"
}

variable "zone" {
  type        = string
  description = "Zone for resources"
}

// VPC //
variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

// DATABASE //
variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "app-db"
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

// 

variable "github_config_url" {
  type        = string
  description = "URL of the repo or org: https://github.com/my-org/my-repo"
}

// //
// APP SECRET //

variable "jwt_secret" {
  type        = string
  description = "JWT Secret for token generation"
  sensitive   = true
}

variable "ssl_cert" {
  type        = string
  description = "ssl certificate"
  sensitive   = true
}
variable "ssl_key" {
  type        = string
  description = "ssl certificate"
  sensitive   = true
}


// REPO GITHUB

variable "github_repo_token" {
  type        = string
  description = "github repo token"
  sensitive   = true
}

// CLUSTER 

variable "cluster_name" {
  description = "Runner Kubernetes cluster"
  type        = string
}

variable "runner_pool_name" {
  description = "Runner Pool name"
  type        = string
}

variable "runner_pool_sa" {
  description = "Runner Pool Service Account"
  type        = string
}

variable "runner_pool_sa_roles" {
  description = "Runner Pool Service Account Roles"
  type        = list(string)
}

variable "arc_runner_name" {
  description = "Runner Kubernetes cluster"
  type        = string
}

variable "deletion_protection" {
  description = "Deletion protection state"
  type        = bool
}

variable "app_name" {
  description = "Application name"
  type        = string
}



variable "app_pool_sa" {
  description = "App Pool Service Account"
  type        = string
}

variable "app_pool_sa_roles" {
  description = "App Pool Service Account Roles"
  type        = list(string)
}

// LOAD BALANCER & DNS //
variable "domain_name" {
  type        = string
  description = "Domain name for the application (e.g., api.yourdomain.com)"
  default     = "api.iac-epitech.com"
}
// OBSERVABILITY //

variable "enable_managed_prometheus" {
  description = "Utiliser GCP Managed Prometheus"
  type        = bool
  default     = true
}

variable "grafana_admin_password" {
  description = "Mot de passe admin Grafana"
  type        = string
  sensitive   = true
}
