variable "project_id" {
  type        = string
  description = "Cloud project ID"
}

variable "region" {
  type        = string
  description = "Region for resources"
}

variable "github_token_secret_name" {
  type        = string
  default     = "repo_token"
  description = "Name of the secret in GCP Secret Manager containing the GitHub token"
}
// USERS GITHUB // 
variable "github_admin_users" {
  type        = list(string)
  default     = []
  description = "List of GitHub usernames with admin permission"
}

variable "github_read_users" {
  type        = list(string)
  default     = []
  description = "List of GitHub usernames with read permission"
}

variable "gcp_iam_members" {
  type = map(list(string))
  default = {
    "jeremie@jjaouen.com" = ["roles/reader", "roles/viewer"]
  }
  description = "Map of user emails to their IAM roles"
}
variable "github_iam_members" {
  type        = map(string)
  default     = {}
  description = "Map of user emails to their IAM roles"
}
