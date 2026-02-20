module "jellyfin" {
  source     = "./jellyfin"
  depends_on = [helm_release.cloudnativepg]

  hcp_client = {
    client_id     = data.aws_ssm_parameter.vault_client_id.value
    client_secret = data.aws_ssm_parameter.vault_client_secret.value
  }
}

module "games" {
  source = "./games"

  vault_backend = {
    kind = kubernetes_manifest.vault_backend.manifest.kind
    name = kubernetes_manifest.vault_backend.manifest.metadata.name
  }
  ecr_repositories = {
    diplomacy_repo = data.terraform_remote_state.ecr.outputs.diplomacy_repo.repository_url
  }
}

module "homeassistant" {
    source = "./homeassistant"
}

module "ollama" {
    source = "./ollama"

    vault_backend ={
        kind = kubernetes_manifest.vault_backend.manifest.kind
        name = kubernetes_manifest.vault_backend.manifest.metadata.name
    }
}
