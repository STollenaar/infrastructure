module "jellyfin" {
  source     = "./jellyfin"
  depends_on = [helm_release.cloudnativepg]

  vault_backend = {
    kind = kubernetes_manifest.vault_backend.manifest.kind
    name = kubernetes_manifest.vault_backend.manifest.metadata.name
  }
}

module "games" {
  source = "./games"

  vault_backend = {
    kind = kubernetes_manifest.vault_backend.manifest.kind
    name = kubernetes_manifest.vault_backend.manifest.metadata.name
  }
  ecr_repositories = {
    diplomacy_repo            = data.terraform_remote_state.ecr.outputs.diplomacy_repo.repository_url
    factorio_archipelago_repo = data.terraform_remote_state.ecr.outputs.factorio_archipelago_repo.repository_url
  }
}

module "homeassistant" {
  source = "./homeassistant"
}

module "ollama" {
  source = "./ollama"

  vault_backend = {
    kind = kubernetes_manifest.vault_backend.manifest.kind
    name = kubernetes_manifest.vault_backend.manifest.metadata.name
  }
}

module "planespotter" {
  source = "./planespotter"

  rtlsdr_adsb_serial = local.rtlsdr_adsb_serial
  vault_backend = {
    kind = kubernetes_manifest.vault_backend.manifest.kind
    name = kubernetes_manifest.vault_backend.manifest.metadata.name
  }
}
