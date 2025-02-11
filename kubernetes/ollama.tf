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
          image = "ollama/ollama:0.5.7"
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

resource "kubernetes_job" "ollama_model_creation" {
  depends_on = [kubernetes_deployment.ollama]

  metadata {
    name = "ollama-model-creation"
    namespace = kubernetes_namespace.ollama.metadata.0.name
  }

  spec {
    template {
      metadata {
        labels = {
          job                                      = "ollama-model-creation"
          "checksum/configmap-mistral-model-files" = kubernetes_config_map.ollama_models.metadata.0.resource_version
        }
      }

      spec {
        container {
          name  = "ollama"
          image = "ollama/ollama:0.5.7"

          command = [
            "/bin/sh",
            "-c",
          ]
          args = [
            <<EOF
                for file in /modelfiles/*.modelfile; do
                    model_name=$(basename "$file" .modelfile)
                    ollama create "$model_name" -f "$file"
                done
            EOF

          ]

          env {
            name  = "OLLAMA_HOST"
            value = "${kubernetes_service.ollama.metadata.0.name}.${kubernetes_namespace.ollama.metadata.0.name}:11434"
          }

          volume_mount {
            name       = "ollama-models"
            mount_path = "/modelfiles"
          }
        }

        restart_policy = "Never"

        volume {
          name = "ollama-models"
          config_map {
            name = kubernetes_config_map.ollama_models.metadata.0.name
          }
        }
      }
    }

    backoff_limit = 4
  }
}

resource "kubernetes_config_map" "ollama_models" {
  metadata {
    name      = "ollama-models"
    namespace = kubernetes_namespace.ollama.metadata.0.name
  }
  data = { for f in fileset("${path.module}/conf/ollama", "*") : f => file("${path.module}/conf/ollama/${f}") }
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
