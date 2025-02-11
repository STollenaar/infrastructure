data "hcp_vault_secrets_app" "surfshark" {
  app_name = "surfshark"
}

## For syncing secrets from hcp vault secrets:
resource "kubernetes_secret" "vault_auth" {
  metadata {
    name      = "default"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    clientID     = var.hcp_client.client_id
    clientSecret = var.hcp_client.client_secret
  }
}

resource "kubernetes_manifest" "hcp_vault_auth" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "HCPAuth"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.jellyfin.metadata.0.name
    }
    spec = {
      allowedNamespaces = ["*"]
      organizationID    = data.hcp_vault_secrets_app.surfshark.organization_id
      projectID         = data.hcp_vault_secrets_app.surfshark.project_id
      servicePrincipal = {
        secretRef = kubernetes_secret.vault_auth.metadata.0.name
      }
    }
  }
}

resource "kubernetes_manifest" "surfshark_openvpn_credentials" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "HCPVaultSecretsApp"
    metadata = {
      name      = "surfshark-openvpn"
      namespace = kubernetes_namespace.jellyfin.metadata.0.name
    }
    spec = {
      appName = "surfshark"
      destination = {
        create = true
        labels = {
          hvs = "true"
        }
        name = "surfshark-openvpn"
      }
      hcpAuthRef   = kubernetes_manifest.hcp_vault_auth.manifest.metadata.name
      refreshAfter = "1h"
    }
  }
}

