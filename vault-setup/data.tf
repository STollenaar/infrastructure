data "aws_ssm_parameter" "vault_client_id" {
  name = "/vault/serviceprincipals/talos/client_id"
}

data "aws_ssm_parameter" "vault_client_secret" {
  name = "/vault/serviceprincipals/talos/client_secret"
}

data "hcp_vault_secrets_secret" "vault_root" {
  app_name    = "proxmox"
  secret_name = "root"
}

data "aws_ssm_parameter" "aws_user_access_key" {
  name = "/iam/vault_user/access_key"
}

data "aws_ssm_parameter" "aws_user_secret_access_key" {
  name = "/iam/vault_user/secret_access_key"
}

data "terraform_remote_state" "kubernetes_state" {
  backend = "s3"
  config = {
    bucket  = "stollenaar-terraform-states"
    key     = "infrastructure/kubernetes/terraform.tfstate"
    region  = "ca-central-1"
    # profile = "personal"
  }
}
