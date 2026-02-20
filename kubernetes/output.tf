output "vault_namespace" {
  value = kubernetes_namespace.vault
}

output "ollama" {
  value = module.ollama.ollama
}

output "github_arc" {
  value = {
    namespace   = kubernetes_namespace_v1.github_actions_runner
    secret_name = kubernetes_secret_v1.controller_manager.metadata.0.name
    version     = local.github_arc_version
  }
}

output "discordbots" {
  value = {
    namespace   = kubernetes_namespace_v1.discordbots
    secret_name = kubernetes_manifest.discordbots_external_secret.manifest.spec.target.name
  }
}
