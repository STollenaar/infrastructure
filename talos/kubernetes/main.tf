resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault_secrets_operator" {
  name       = "vault-secrets-operator"
  version    = "0.3.4"
  namespace  = kubernetes_namespace.vault.metadata.0.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"

  values = [file("${path.module}/conf/vault-secrets-operator-values.yaml")]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  version    = "0.9.7"
  namespace  = kubernetes_namespace.vault.metadata.0.name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
}

## For syncing secrets from hcp vault secrets:
resource "kubernetes_secret" "vault_auth" {
  metadata {
    name      = "default"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  data = {
    clientID     = data.aws_ssm_parameter.vault_client_id.value
    clientSecret = data.aws_ssm_parameter.vault_client_secret.value
  }
}

resource "kubernetes_manifest" "hcp_vault_auth" {
  depends_on = [helm_release.vault_secrets_operator]
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "HCPAuth"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.vault.metadata.0.name
    }
    spec = {
      allowedNamespaces = ["*"]
      organizationID    = hcp_vault_secrets_app.proxmox_vault.organization_id
      projectID         = hcp_vault_secrets_app.proxmox_vault.project_id
      servicePrincipal = {
        secretRef = kubernetes_secret.vault_auth.metadata.0.name
      }
    }
  }
}


module "jellyfin" {
  source = "./jellyfin"

  hcp_client = {
    client_id     = data.aws_ssm_parameter.vault_client_id.value
    client_secret = data.aws_ssm_parameter.vault_client_secret.value
  }
}
