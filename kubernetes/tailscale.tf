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
  depends_on = [kubernetes_manifest.tailscale_keys]
  name       = "tailscale"
  version    = "1.78.3"
  namespace  = kubernetes_namespace.tailscale.metadata.0.name
  chart      = "tailscale-operator"
  repository = "https://pkgs.tailscale.com/helmcharts"
  values     = [file("${path.module}/conf/tailscale-values.yaml")]
}

## For syncing secrets from hcp vault secrets:
resource "kubernetes_secret" "vault_tailscale_auth" {
  metadata {
    name      = "vault-tailscale-auth"
    namespace = kubernetes_namespace.tailscale.metadata.0.name
  }
  data = {
    clientID     = data.aws_ssm_parameter.vault_client_id.value
    clientSecret = data.aws_ssm_parameter.vault_client_secret.value
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

resource "kubernetes_manifest" "hcp_vault_tailscale_auth" {
  depends_on = [helm_release.vault_secrets_operator]
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "HCPAuth"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.tailscale.metadata.0.name
    }
    spec = {
      allowedNamespaces = ["*"]
      organizationID    = hcp_vault_secrets_app.proxmox_vault.organization_id
      projectID         = hcp_vault_secrets_app.proxmox_vault.project_id
      servicePrincipal = {
        secretRef = kubernetes_secret.vault_tailscale_auth.metadata.0.name
      }
    }
  }
}

resource "kubernetes_manifest" "tailscale_keys" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "HCPVaultSecretsApp"
    metadata = {
      name      = "tailscale-keys"
      namespace = kubernetes_namespace.tailscale.metadata.0.name
    }
    spec = {
      appName = "tailscale"
      destination = {
        create = true
        labels = {
          hvs = "true"
        }
        name = "operator-oauth"
      }
      hcpAuthRef   = kubernetes_manifest.hcp_vault_tailscale_auth.manifest.metadata.name
      refreshAfter = "1h"
    }
  }
}
