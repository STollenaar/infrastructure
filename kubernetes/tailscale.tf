resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"

    }
  }
}

resource "helm_release" "tailscale" {
  depends_on = [kubernetes_secret.tailscale]
  name       = "tailscale"
  version    = "1.88.3"
  namespace  = kubernetes_namespace.tailscale.id
  chart      = "tailscale-operator"
  repository = "https://pkgs.tailscale.com/helmcharts"
  values     = [file("${path.module}/conf/tailscale-values.yaml")]
}

## For syncing secrets from hcp vault secrets:
resource "kubernetes_secret" "vault_tailscale_auth" {
  metadata {
    name      = "vault-tailscale-auth"
    namespace = kubernetes_namespace.tailscale.id
  }
  data = {
    clientID     = data.aws_ssm_parameter.vault_client_id.value
    clientSecret = data.aws_ssm_parameter.vault_client_secret.value
  }
}

resource "kubernetes_secret" "tailscale" {
  metadata {
    name      = "operator-oauth"
    namespace = kubernetes_namespace.tailscale.id
  }
  data = {
    client_id     = data.aws_ssm_parameter.tailscale_client_id.value
    client_secret = data.aws_ssm_parameter.tailscale_client_secret.value
  }
}

resource "kubernetes_cluster_role_binding_v1" "tailscale_auth_binding" {
  metadata {
    name = "1guitargun1@gmail.com"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "1guitargun1@gmail.com"
  }
}
