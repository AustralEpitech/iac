resource "google_iam_workload_identity_pool" "github-action-wif-pool" {
  workload_identity_pool_id = "github-action-wif-pool"
  project                   = var.project_id
}

resource "google_service_account" "github_action" {
  account_id   = "github-action-sa"
  display_name = "GitHub Actions Service Account"
  project      = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github-provider-oidc" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-action-wif-pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  project                            = var.project_id
  attribute_condition                = "assertion.repository == '${var.github_org}/${var.github_repo}'"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.aud"        = "assertion.aud"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = var.github_url
  }
}

resource "google_service_account_iam_binding" "github_action_wif_user" {
  service_account_id = google_service_account.github_action.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-action-wif-pool.name}/attribute.repository/${var.github_org}/${var.github_repo}"
  ]
}

resource "google_project_iam_member" "github_action_sa_roles" {
  for_each = toset(var.github_action_sa_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.github_action.email}"
}
