output "ollama" {
  value = {
    namespace = kubernetes_namespace.ollama
    service   = kubernetes_service.ollama
  }
}
