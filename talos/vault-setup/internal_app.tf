data "vault_policy_document" "internal_app" {
  rule {
    path         = "aws/creds/*"
    capabilities = ["read", "list"]
    description  = "allow to read all credentials"
  }
  rule {
    path         = "secret/data/ecr-auth"
    capabilities = ["read", "patch", "update"]
    description  = "allow to manage the ecr-auth secret"
  }
}

resource "vault_kubernetes_secret_backend_role" "internal_app" {
  backend                       = vault_kubernetes_secret_backend.kubernetes.path
  name                          = "internal-app"
  allowed_kubernetes_namespaces = ["*"] #TODO: Change to non critical namespaces

  kubernetes_role_type = "Role"
  generated_role_rules = <<EOF
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
EOF
}

resource "vault_kubernetes_auth_backend_role" "internal_app" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = vault_kubernetes_secret_backend_role.internal_app.name
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = vault_kubernetes_secret_backend_role.internal_app.allowed_kubernetes_namespaces
  token_ttl                        = 3600
  token_policies                   = [vault_policy.internal_app.name]
}

resource "vault_policy" "internal_app" {
  name   = "internal-app"
  policy = data.vault_policy_document.internal_app.hcl
}
