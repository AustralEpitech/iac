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


// Github credentials Variables
variable "github_config_url" {
  type        = string
  description = "URL of the repo or org: https://github.com/my-org/my-repo"
}


// ARC Variable

variable "arc_runner_name" {
  description = "Runner Kubernetes cluster"
  type        = string
}

variable "runner_image_url" {
  description = "Custom runner image URL from Artifact Registry"
  type        = string
  default     = "" # Empty means use default image
}
