output "vault_namespace" {
  value = kubernetes_namespace.vault
}

output "ollama" {
  value = {
    namespace = kubernetes_namespace.ollama
    service = kubernetes_service.ollama
  }
}