data "aws_ssm_parameter" "vault_client_id" {
  name = "/vault/serviceprincipals/talos/client_id"
}

data "aws_ssm_parameter" "vault_client_secret" {
  name = "/vault/serviceprincipals/talos/client_secret"
}

data "aws_ssm_parameter" "github_arc_token" {
  name = "/github/github_arc"
}

data "aws_ssm_parameter" "vault_user_access_key" {
  name = "/iam/vault_user/access_key"
}

data "aws_ssm_parameter" "vault_user_secret_access_key" {
  name = "/iam/vault_user/secret_access_key"
}

data "aws_ssm_parameter" "route53_user_access_key" {
  name = "/iam/route53_user/access_key"
}

data "aws_ssm_parameter" "route53_user_secret_access_key" {
  name = "/iam/route53_user/secret_access_key"
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "aws_iam" {
  backend = "s3"
  config = {
    region = "ca-central-1"
    bucket = "stollenaar-terraform-states"
    key    = "infrastructure/aws/iam/terraform.tfstate"
  }
}

data "aws_ssm_parameter" "diplomacy_auth" {
  name = "/diplomacy/password"
  with_decryption = true
}
