
resource "kubernetes_namespace_v1" "arc_runners" {
  metadata {
    name = "arc-runners"
  }
}
resource "helm_release" "arc_controller" {
  name             = "arc-system"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  version          = "0.9.0"
  namespace        = "arc-systems"
  create_namespace = true
}

# Fetch GitHub token from Secret Manager
# The token is stored in Secret Manager by infrastructure/secret.tf
data "google_secret_manager_secret_version" "github_repo_token" {
  secret  = "github-repo-token"
  version = "latest"
}

resource "kubernetes_secret_v1" "github_secret" {
  metadata {
    name      = "github-secret"
    namespace = kubernetes_namespace_v1.arc_runners.metadata[0].name
  }

  data = {
    github_token = data.google_secret_manager_secret_version.github_repo_token.secret_data
  }
}

resource "helm_release" "arc_runner_set" {
  name       = var.arc_runner_name
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  version    = "0.9.0"
  namespace  = kubernetes_namespace_v1.arc_runners.metadata[0].name

  depends_on = [helm_release.arc_controller]

  set {
    name  = "githubConfigUrl"
    value = var.github_config_url
  }
  set {
    name  = "template.spec.containers[0].name"
    value = "runner"
  }

  set {
    name  = "githubConfigSecret"
    value = kubernetes_secret_v1.github_secret.metadata[0].name
  }

  # Set custom runner labels so workflows can target them
  set {
    name  = "runnerGroup"
    value = "default"
  }

  set {
    name  = "runnerScaleSetName"
    value = var.arc_runner_name
  }

  # 1. Point to your Custom Image in Artifact Registry
  set {
    name  = "template.spec.containers[0].image"
    value = var.runner_image_url
  }

  set {
    name  = "template.spec.containers[0].imagePullPolicy"
    value = "Always"
  }

  set {
    name  = "template.spec.tolerations[0].key"
    value = "dedicated"
  }
  set {
    name  = "template.spec.tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "template.spec.tolerations[0].value"
    value = "runner"
  }
  set {
    name  = "template.spec.tolerations[0].effect"
    value = "NoSchedule"
  }
  set {
    name  = "template.spec.nodeSelector.workload-type"
    value = "runner"
  }
}
