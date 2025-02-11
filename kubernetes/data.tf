data "aws_ssm_parameter" "vault_client_id" {
  name = "/vault/serviceprincipals/talos/client_id"
}

data "aws_ssm_parameter" "vault_client_secret" {
  name = "/vault/serviceprincipals/talos/client_secret"
}

data "aws_caller_identity" "current" {}

data "hcp_vault_secrets_secret" "vault_user_access_key" {
  app_name    = data.terraform_remote_state.aws_iam.outputs.hcp.app_name
  secret_name = data.terraform_remote_state.aws_iam.outputs.hcp.vault_user_access_key
}

data "hcp_vault_secrets_secret" "vault_user_secret_access_key" {
  app_name    = data.terraform_remote_state.aws_iam.outputs.hcp.app_name
  secret_name = data.terraform_remote_state.aws_iam.outputs.hcp.vault_user_secret_access_key
}

data "terraform_remote_state" "aws_iam" {
  backend = "s3"
  config = {
    region = "ca-central-1"
    bucket = "stollenaar-terraform-states"
    key    = "infrastructure/aws/iam/terraform.tfstate"
  }
}
