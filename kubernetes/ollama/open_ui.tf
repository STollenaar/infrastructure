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
