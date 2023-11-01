data "aws_ssm_parameter" "vault_client_id" {
  name = "/vault/serviceprincipals/talos/client_id"
}

data "aws_ssm_parameter" "vault_client_secret" {
  name = "/vault/serviceprincipals/talos/client_secret"
}

data "aws_caller_identity" "current" {}

data "hcp_vault_secrets_secret" "tailscale_api_key" {
  app_name    = "tailscale"
  secret_name = "api_key"
}

data "hcp_vault_secrets_secret" "tailscale_tailnet_name" {
  app_name    = "tailscale"
  secret_name = "tailnet_name"
}