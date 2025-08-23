resource "aws_iam_user" "vault_user" {
  name = "vault"
}

resource "aws_iam_user" "vault_unseal_user" {
  name = "vault-unseal"
}

resource "aws_iam_access_key" "vault_user_key" {
  user = aws_iam_user.vault_user.name
}

resource "aws_iam_access_key" "vault_unseal_user_key" {
  user = aws_iam_user.vault_unseal_user.name
}

resource "aws_iam_user_policy" "vault_user_policy" {
  name   = "hashicorp-vault"
  user   = aws_iam_user.vault_user.name
  policy = data.aws_iam_policy_document.hashicorp_vault_document.json
}

resource "aws_iam_user_policy" "vault_unseal_user_policy" {
  name   = "hashicorp-vault"
  user   = aws_iam_user.vault_unseal_user.name
  policy = data.aws_iam_policy_document.hashicorp_vault_unseal_document.json
}

resource "aws_iam_role" "vault_ecr" {
  name               = "vault-ecr"
  assume_role_policy = data.aws_iam_policy_document.vault_ecr_assume_role.json
  path               = "/vault/"
}
resource "aws_iam_role_policy" "vault_ecr_role_policy" {
  name   = "vault-ecr"
  role   = aws_iam_role.vault_ecr.id
  policy = data.aws_iam_policy_document.vault_ecr_role_policy.json
}

resource "aws_iam_role" "extenral_dns_role" {
  name = "external-dns"
  assume_role_policy = data.aws_iam_policy_document.vault_ecr_assume_role.json
}

resource "aws_iam_role_policy" "extenral_dns_role_policy" {
  name = "external-dns"
  role = aws_iam_role.extenral_dns_role.id
  policy = data.aws_iam_policy_document.extenral_dns_role_policy.json
}