provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "hcp" {
  client_id     = data.aws_ssm_parameter.vault_client_id.value
  client_secret = data.aws_ssm_parameter.vault_client_secret.value
}

provider "helm" {
  experiments {
    manifest = true
  }
  kubernetes {
    config_path = "~/.kube/config"
  }
}
