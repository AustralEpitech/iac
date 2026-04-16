variable "project_id" {
  type        = string
  description = "Cloud project ID"
}

variable "region" {
  type        = string
  description = "Region for resources"
}

// OIDC GITHUB  //

variable "github_url" {
  type    = string
  default = "https://token.actions.githubusercontent.com"
}

variable "github_project_id" {
  type        = string
  description = "Github Project ID"
}

variable "github_org" {
  type        = string
  description = "GitHub organization allowed to authenticate"
}

variable "github_repo" {
  type        = string
  description = "Github Repository"
}

variable "github_action_sa_roles" {
  type        = list(string)
  default     = []
  description = "List of GitHub Actions IAM Policies"
}


variable "app_name" {
  description = "Application name"
  type        = string
}
