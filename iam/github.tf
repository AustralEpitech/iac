data "github_repository" "iac_repo" {
  name = "InfrastructureAsCode"
}

resource "github_repository_collaborators" "collaborators" {
  repository = data.github_repository.iac_repo.name


  dynamic "user" {
    for_each = {
      for user, role in var.github_iam_members :
      user => {
        name = user
        role = role
      }
    }
    content {
      permission = user.value.role
      username   = user.value.name
    }
  }

}
