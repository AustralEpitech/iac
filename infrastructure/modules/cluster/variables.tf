// GCP Variables
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

// Cluster Variable

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

variable "app_pool_sa" {
  description = "App Pool Service Account"
  type        = string
}

variable "app_pool_sa_roles" {
  description = "App Pool Service Account Roles"
  type        = list(string)
}

variable "deletion_protection" {
  description = "Deletion protection state"
  type        = bool
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}
