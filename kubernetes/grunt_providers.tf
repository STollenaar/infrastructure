# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa

provider "aws" {
  region = "ca-central-1"
}


provider "kubernetes" {
  config_path = "/home/stollenaar/.kube/config"
}


provider "hcp" {
  client_id     = data.aws_ssm_parameter.vault_client_id.value
  client_secret = data.aws_ssm_parameter.vault_client_secret.value
}


provider "helm" {
  kubernetes {
    config_path = "/home/stollenaar/.kube/config"
  }
}



