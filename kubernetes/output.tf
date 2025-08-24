output "vault_namespace" {
  value = kubernetes_namespace.vault
}

output "ollama" {
  value = {
    namespace = kubernetes_namespace.ollama
    service   = kubernetes_service.ollama
  }
}

output "github_arc" {
  value = {
    namespace   = kubernetes_namespace_v1.github_actions_runner
    secret_name = kubernetes_secret_v1.controller_manager.metadata.0.name
    version     = local.github_arc_version
  }
}
