resource "kubernetes_namespace" "ollama" {
  metadata {
    name = "ollama"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "ollama_pvc" {
  metadata {
    name      = "ollama-cache"
    namespace = kubernetes_namespace.ollama.id
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
    namespace = kubernetes_namespace.ollama.id
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

        container {
          name  = "ollama"
          image = "ollama/ollama:0.16.2"
          args  = ["serve"]

          env {
            name  = "OLLAMA_MODEL"
            value = "mistral"
          }

          env {
            name  = "OLLAMA_NEW_ENGINE"
            value = "1"
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
    name      = "ollama-model-creation"
    namespace = kubernetes_namespace.ollama.id
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
          image = "ollama/ollama:0.16.2"

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
            value = "${kubernetes_service.ollama.metadata.0.name}.${kubernetes_namespace.ollama.id}:11434"
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
    namespace = kubernetes_namespace.ollama.id
  }
  data = { for f in fileset("${path.module}/conf/ollama", "*") : f => file("${path.module}/conf/ollama/${f}") }
}

resource "kubernetes_service" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.ollama.id
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

resource "kubernetes_manifest" "ollama_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace.ollama.id
    }
    spec = {
      secretStoreRef = {
        name = var.vault_backend.name
        kind = var.vault_backend.kind
      }
      target = {
        name = "regcred"
        template = {
          type          = "kubernetes.io/dockerconfigjson"
          mergePolicy   = "Replace"
          engineVersion = "v2"
        }
      }
      data = [
        {
          secretKey = ".dockerconfigjson"
          remoteRef = {
            key      = "ecr-auth"
            property = ".dockerconfigjson"
          }
        }
      ]
    }
  }
}
