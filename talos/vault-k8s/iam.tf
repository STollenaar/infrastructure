## VAULT USER ###
data "aws_iam_policy_document" "hashicorp_vault_document" {
  statement {
    sid       = "VaultUserMgmt"
    effect    = "Allow"
    resources = ["arn:aws:iam::${var.aws_caller_identity.account_id}:user/vault-*"]
    actions = [
      "iam:AttachUserPolicy",
      "iam:CreateAccessKey",
      "iam:CreateUser",
      "iam:DeleteAccessKey",
      "iam:DeleteUser",
      "iam:DeleteUserPolicy",
      "iam:DetachUserPolicy",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserPolicies",
      "iam:PutUserPolicy",
      "iam:RemoveUserFromGroup"
    ]
  }
  statement {
    sid       = "VaultRoleAssume"
    effect    = "Allow"
    resources = ["arn:aws:iam::${var.aws_caller_identity.account_id}:role/*"]
    actions   = ["sts:AssumeRole"]
  }
}

resource "aws_iam_user" "vault_user" {
  name = "vault"
}

resource "aws_iam_access_key" "vault_user_key" {
  user = aws_iam_user.vault_user.name
}

resource "aws_iam_user_policy" "vault_user_policy" {
  name   = "hashicorp-vault"
  user   = aws_iam_user.vault_user.name
  policy = data.aws_iam_policy_document.hashicorp_vault_document.json
}

resource "hcp_vault_secrets_app" "aws" {
  app_name    = "aws"
  description = "aws parameters app"
}

resource "hcp_vault_secrets_secret" "vault_user_access_key" {
  app_name     = hcp_vault_secrets_app.aws.app_name
  secret_name  = "access_key"
  secret_value = aws_iam_access_key.vault_user_key.id
}

resource "hcp_vault_secrets_secret" "vault_user_secret_access_key" {
  app_name     = hcp_vault_secrets_app.aws.app_name
  secret_name  = "secret_access_key"
  secret_value = aws_iam_access_key.vault_user_key.secret
}

## TALOS K8S ROLE

data "aws_iam_policy_document" "vault_ecr_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.vault_user.arn]
    }
  }
}

data "aws_iam_policy_document" "vault_ecr_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
    resources = [
      "arn:aws:ecr:*:${var.aws_caller_identity.account_id}:repository/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeRegistry",
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
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
