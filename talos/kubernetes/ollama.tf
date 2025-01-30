resource "kubernetes_namespace" "ollama" {
  metadata {
    name = "ollama"
  }
}

resource "kubernetes_persistent_volume_claim" "ollama_pvc" {
  metadata {
    name      = "ollama-cache"
    namespace = kubernetes_namespace.ollama.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.ollama.metadata.0.name
    labels = {
      app = "ollama"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "ollama"
      }
    }

    template {
      metadata {
        labels = {
          app = "ollama"
        }
      }

      spec {
        container {
          name  = "ollama"
          image = "ollama/ollama:latest"
          args  = ["serve"]

          env {
            name  = "OLLAMA_MODEL"
            value = "mistral"
          }

          resources {
            limits = {
              memory = "16Gi"
            }
            requests = {
              memory = "8Gi"
            }
          }

          volume_mount {
            name       = "ollama-cache"
            mount_path = "/root/.ollama"
          }


          port {
            container_port = 11434
          }
        }

        volume {
          name = "ollama-cache"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ollama_pvc.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.ollama.metadata.0.name
  }

  spec {
    selector = {
      app = "ollama"
    }

    port {
      port        = 11434
      target_port = 11434
    }
  }
}
