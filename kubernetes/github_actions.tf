locals {
  github_arc_version = "0.11.0"
}

resource "kubernetes_namespace_v1" "github_actions_runner" {
  metadata {
    name = "github-arc"
  }
}

resource "kubernetes_secret_v1" "controller_manager" {
  metadata {
    name      = "controller-manager"
    namespace = kubernetes_namespace_v1.github_actions_runner.metadata.0.name
  }
  data = {
    github_token = data.aws_ssm_parameter.github_arc_token.value
  }
}

resource "helm_release" "github_arc" {
  name       = "github-arc"
  namespace  = kubernetes_namespace_v1.github_actions_runner.metadata.0.name
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  version    = local.github_arc_version
  values     = []
}
