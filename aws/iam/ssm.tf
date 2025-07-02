resource "aws_ssm_parameter" "vault_unseal_user_access_key" {
  name = "/iam/vault_unseal_user/access_key"
  type = "SecureString"
  value = aws_iam_access_key.vault_unseal_user_key.id
}

resource "aws_ssm_parameter" "vault_unseal_user_secret_access_key" {
  name = "/iam/vault_unseal_user/secret_access_key"
  type = "SecureString"
  value = aws_iam_access_key.vault_unseal_user_key.secret
}

resource "aws_ssm_parameter" "vault_user_access_key" {
  name = "/iam/vault_user/access_key"
  type = "SecureString"
  value = aws_iam_access_key.vault_user_key.id
}

resource "aws_ssm_parameter" "vault_user_secret_access_key" {
  name = "/iam/vault_user/secret_access_key"
  type = "SecureString"
  value = aws_iam_access_key.vault_user_key.secret
}

resource "aws_ssm_parameter" "route53_user_access_key" {
  name = "/iam/route53_user/access_key"
  type = "SecureString"
  value = aws_iam_access_key.route53_user_key.id
}

resource "aws_ssm_parameter" "route53_user_secret_access_key" {
  name = "/iam/route53_user/secret_access_key"
  type = "SecureString"
  value = aws_iam_access_key.route53_user_key.secret
}