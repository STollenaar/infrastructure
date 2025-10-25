locals {
  github_arc_version = "0.13.0"
}

resource "kubernetes_namespace_v1" "github_actions_runner" {
  metadata {
    name = "github-arc"

    labels = {
      "cmstate.spicedelver.me"             = "opt-out"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_secret_v1" "controller_manager" {
  metadata {
    name      = "controller-manager"
    namespace = kubernetes_namespace_v1.github_actions_runner.id
  }
  data = {
    github_token = data.aws_ssm_parameter.github_arc_token.value
  }
}

resource "helm_release" "github_arc" {
  name       = "github-arc"
  namespace  = kubernetes_namespace_v1.github_actions_runner.id
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  version    = local.github_arc_version
  values     = []
  set = [
    {
      name  = "resources.requests.memory"
      value = "40Mi"
    },
    {
      name  = "resources.limits.memory"
      value = "80Mi"
    },

    {
      name  = "resources.requests.cpu"
      value = "10m"
    },
  ]
}
