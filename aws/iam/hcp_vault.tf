resource "hcp_vault_secrets_app" "aws" {
  app_name    = "aws"
  description = "aws parameters app"
}

resource "hcp_vault_secrets_secret" "vault_user_access_key" {
  app_name     = hcp_vault_secrets_app.aws.app_name
  secret_name  = "access_key"
  secret_value = aws_iam_access_key.vault_unseal_user_key.id
}

resource "hcp_vault_secrets_secret" "vault_user_secret_access_key" {
  app_name     = hcp_vault_secrets_app.aws.app_name
  secret_name  = "secret_access_key"
  secret_value = aws_iam_access_key.vault_unseal_user_key.secret
}
