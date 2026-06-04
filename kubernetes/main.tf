module "jellyfin" {
  source     = "./jellyfin"
  depends_on = [helm_release.cloudnativepg]
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
