data "aws_ssm_parameter" "vault_client_id" {
  name = "/vault/serviceprincipals/talos/client_id"
}

data "aws_ssm_parameter" "vault_client_secret" {
  name = "/vault/serviceprincipals/talos/client_secret"
}

data "aws_caller_identity" "current" {}

## VAULT UNSEAL USER ##
data "aws_iam_policy_document" "hashicorp_vault_unseal_document" {
  statement {
    sid    = "VaultKMSUnseal"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = ["*"]
  }
}

## VAULT USER ###
data "aws_iam_policy_document" "hashicorp_vault_document" {
  statement {
    sid       = "VaultUserMgmt"
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"]
    actions = [
      #   "iam:AttachUserPolicy",
      "iam:CreateAccessKey",
      #   "iam:CreateUser",
      "iam:DeleteAccessKey",
      #   "iam:DeleteUser",
      #   "iam:DeleteUserPolicy",
      #   "iam:DetachUserPolicy",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserPolicies",
      #   "iam:PutUserPolicy",
      #   "iam:RemoveUserFromGroup"
    ]
  }
  statement {
    sid       = "VaultRoleAssume"
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"]
    actions   = ["sts:AssumeRole"]
  }
  #   statement {
  #     sid    = "VaultKMSUnseal"
  #     effect = "Allow"
  #     actions = [
  #       "kms:Encrypt",
  #       "kms:Decrypt",
  #       "kms:DescribeKey",
  #     ]
  #     resources = ["*"]
  #   }
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
      "arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:repository/*"
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
