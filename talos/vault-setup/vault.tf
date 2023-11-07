resource "vault_aws_secret_backend" "aws_client" {
  access_key = data.hcp_vault_secrets_secret.aws_user_access_key.secret_value
  secret_key = data.hcp_vault_secrets_secret.aws_user_secret_access_key.secret_value
}

resource "vault_aws_secret_backend_role" "vault_ecr" {
  backend         = vault_aws_secret_backend.aws_client.path
  name            = data.terraform_remote_state.kubernetes_state.outputs.vault_ecr_role.id
  credential_type = "assumed_role"
  role_arns       = [data.terraform_remote_state.kubernetes_state.outputs.vault_ecr_role.arn] #TODO: fetch dynamically
}

resource "vault_kubernetes_secret_backend" "kubernetes" {
  path                 = "kubernetes"
  description          = "kubernetes secrets engine description"
  disable_local_ca_jwt = false
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
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_role" "internal_app" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = vault_kubernetes_secret_backend_role.internal_app.name
  bound_service_account_names      = [vault_kubernetes_secret_backend_role.internal_app.name]
  bound_service_account_namespaces = vault_kubernetes_secret_backend_role.internal_app.allowed_kubernetes_namespaces
  token_ttl                        = 3600
  token_policies                   = [vault_policy.internal_app.name]
}

resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["vault"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.external_secrets.name]
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_auth_config" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default.svc:443"
  disable_iss_validation = "true"

  issuer = "https://kubernetes.default.svc"
}

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

resource "vault_policy" "internal_app" {
  name   = "internal-app"
  policy = data.vault_policy_document.internal_app.hcl
}

data "vault_policy_document" "external_secrets" {
  rule {
    path         = "secret/data/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow to manage all secrets"
  }
}

resource "vault_policy" "external_secrets" {
  name   = "external-secrets"
  policy = data.vault_policy_document.external_secrets.hcl
}
