resource "vault_aws_secret_backend" "aws_client" {
  access_key = data.hcp_vault_secrets_secret.aws_user_access_key.secret_value
  secret_key = data.hcp_vault_secrets_secret.aws_user_secret_access_key.secret_value
}

resource "vault_kubernetes_secret_backend" "kubernetes" {
  path                 = "kubernetes"
  description          = "kubernetes secrets engine description"
  disable_local_ca_jwt = false
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_auth_config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc:443"
  disable_iss_validation = "true"

  issuer = "https://kubernetes.default.svc"
}

resource "vault_mount" "secrets" {
  path = "secret"
  type = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
  description = "kv secrets manager"
}

resource "vault_kv_secret_v2" "secret" {
  mount = vault_mount.secrets.path
  name = "ecr-auth"
  data_json = jsonencode(
    {
      ".dockerconfigjson" = "foo",
    }
  )
  lifecycle {
    ignore_changes = [data_json]
  }
}
