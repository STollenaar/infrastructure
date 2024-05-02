
data "vault_policy_document" "external_secrets" {
  rule {
    path         = "secret/data/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow to manage all secrets"
  }
}

resource "vault_aws_secret_backend_role" "vault_ecr" {
  backend         = vault_aws_secret_backend.aws_client.path
  name            = data.terraform_remote_state.kubernetes_state.outputs.vault_ecr_role.id
  credential_type = "assumed_role"
  role_arns       = [data.terraform_remote_state.kubernetes_state.outputs.vault_ecr_role.arn] #TODO: fetch dynamically
}

resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["vault"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.external_secrets.name]
}

resource "vault_policy" "external_secrets" {
  name   = "external-secrets"
  policy = data.vault_policy_document.external_secrets.hcl
}