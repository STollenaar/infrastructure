
provider "vault" {
  token   = data.hcp_vault_secrets_secret.vault_root.secret_value
  address = "http://localhost:8200"
}

provider "hcp" {
  client_id     = data.aws_ssm_parameter.vault_client_id.value
  client_secret = data.aws_ssm_parameter.vault_client_secret.value
}
