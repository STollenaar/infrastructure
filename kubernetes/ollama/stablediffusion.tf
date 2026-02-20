resource "kubernetes_persistent_volume_claim_v1" "sd_models_pvc" {
  metadata {
    name      = "sd-models"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "sd_outputs_pvc" {
  metadata {
    name      = "sd-outputs"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
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

resource "kubernetes_deployment_v1" "stable_diffusion" {
  metadata {
    name      = "stable-diffusion"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
  }

  spec {
    replicas = 0

    selector {
      match_labels = {
        app = "stable-diffusion"
      }
    }

    template {
      metadata {
        labels = {
          app = "stable-diffusion"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "nvidia.com/gpu.present"
                  operator = "In"
                  values   = ["true"]
                }
              }
            }
          }
        }

        runtime_class_name = "nvidia"
        image_pull_secrets {
          name = kubernetes_manifest.ollama_external_secret.manifest.spec.target.name
        }

        container {
          name    = "stable-diffusion"
          image   = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/stable-diffusion:master-467-0e52afc"
          command = ["/sd-server"]
          args = [
            "--listen-ip",
            "0.0.0.0",
            "--listen-port",
            "7860",
            "--diffusion-model",
            "/models/z_image_turbo-Q2_K.gguf",
            "--vae",
            "/models/ae.safetensors",
            "--llm",
            "/models/Qwen3-4B-Instruct-2507-UD-IQ1_S.gguf",
            "--offload-to-cpu"
          ]

          volume_mount {
            name       = "models"
            mount_path = "/models"
          }

          volume_mount {
            name       = "outputs"
            mount_path = "/outputs"
          }

          port {
            container_port = 7860
          }
        }

        volume {
          name = "models"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.sd_models_pvc.metadata.0.name
          }
        }

        volume {
          name = "outputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.sd_outputs_pvc.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_service" "stable_diffusion" {
  metadata {
    name      = "stable-diffusion"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
  }

  spec {
    selector = {
      app = "stable-diffusion"
    }

    port {
      protocol    = "TCP"
      port        = 7860
      target_port = 7860
    }
  }
}
