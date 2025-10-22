resource "kubernetes_namespace" "ollama" {
  metadata {
    name = "ollama"
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
          image = "ollama/ollama:0.12.6"
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

resource "kubernetes_deployment" "open_webui" {
  metadata {
    name      = "open-webui"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "open-webui"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "open-webui"
      }
    }

    template {
      metadata {
        labels = {
          app = "open-webui"
        }
      }

      spec {
        container {
          name  = "open-webui"
          image = "ghcr.io/open-webui/open-webui:main"

          port {
            container_port = 8080
          }

          env {
            name  = "OLLAMA_BASE_URL"
            value = "http://${kubernetes_service.ollama.metadata.0.name}.${kubernetes_namespace.ollama.id}.svc.cluster.local:11434"
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "800Mi"
            }
            limits = {
              memory = "2Gi"
            }
          }

          tty = true

          volume_mount {
            name       = "webui-volume"
            mount_path = "/app/backend/data"
          }
        }

        volume {
          name = "webui-volume"

          persistent_volume_claim {
            claim_name = "open-webui-pvc"
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
          image = "ollama/ollama:0.12.6"

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

resource "kubernetes_service" "open_webui" {
  metadata {
    name      = "open-webui-service"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "open-webui"
    }
  }

  spec {
    selector = {
      app = "open-webui"
    }

    port {
      protocol    = "TCP"
      port        = 8080 # Cluster-IP port
      target_port = 8080 # Container port
    }
  }
}

resource "kubernetes_persistent_volume_claim" "open_webui_pvc" {
  metadata {
    name      = "open-webui-pvc"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "open-webui"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_ingress_v1" "open_webui_ingress" {
  metadata {
    name      = "open-webui-ingress"
    namespace = kubernetes_namespace.ollama.id
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    rule {
      host = "ollama.home.spicedelver.me"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.open_webui.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "ollama.home.spicedelver.me"
      ]
      secret_name = "ollama-tls"
    }
  }
}
