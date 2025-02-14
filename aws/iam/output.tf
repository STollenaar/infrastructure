output "iam_users" {
  value = {
    vault_user   = aws_iam_user.vault_user
    route53_user = aws_iam_user.route53_user
  }
}

output "iam_roles" {
  value = {
    vault_ecr_role = aws_iam_role.vault_ecr
  }
}

output "hcp" {
  value = {
    app_name                       = hcp_vault_secrets_app.aws.app_name
    vault_user_access_key          = hcp_vault_secrets_secret.vault_user_access_key.secret_name
    vault_user_secret_access_key   = hcp_vault_secrets_secret.vault_user_secret_access_key.secret_name
    route53_user_access_key        = hcp_vault_secrets_secret.route53_user_access_key.secret_name
    route53_user_secret_access_key = hcp_vault_secrets_secret.route53_user_secret_access_key.secret_name
  }
}
