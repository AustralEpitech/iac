resource "google_project_iam_member" "members" {
  for_each = merge([
    for user, roles in var.gcp_iam_members : {
      for role in roles :
      "${user}-${role}" => {
        user = user
        role = role
      }
    }
  ]...)

  project = var.project_id
  role    = each.value.role
  member  = "user:${each.value.user}"
}
