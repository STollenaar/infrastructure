output "vault_user" {
  value = aws_iam_user.vault_user
}

output "vault_ecr_role" {
  value = aws_iam_role.vault_ecr
}

output "hcp" {
  value = {
    app_name                     = hcp_vault_secrets_app.aws.app_name
    vault_user_access_key        = hcp_vault_secrets_secret.vault_user_access_key.secret_name
    vault_user_secret_access_key = hcp_vault_secrets_secret.vault_user_secret_access_key.secret_name
  }
}
