resource "kubernetes_config_map" "litellm_config" {
  metadata {
    name      = "litellm-config"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "litellm"
    }
  }
  data = {
    "config.yaml" = file("${path.module}/conf/litellm/config.yaml")
  }
}

resource "kubernetes_deployment" "litellm" {
  metadata {
    name      = "litellm"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "litellm"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "litellm"
      }
    }

    template {
      metadata {
        labels = {
          app = "litellm"
        }
        annotations = {
          "checksum/config" = sha256(kubernetes_config_map.litellm_config.data["config.yaml"])
        }
      }

      spec {
        init_container {
          name    = "create-db"
          image   = "postgres:18.4-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.ollama.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'litellm'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.ollama.id}.svc.cluster.local -U postgres litellm"
          ]
          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }

        container {
          name  = "litellm"
          image = "ghcr.io/berriai/litellm:main-stable"
          args  = ["--config", "/app/config.yaml", "--port", "4000"]

          port {
            container_port = 4000
          }

          env {
            name  = "OLLAMA_BASE_URL"
            value = "http://${kubernetes_service.ollama.metadata.0.name}.${kubernetes_namespace.ollama.id}.svc.cluster.local:11434"
          }
          env {
            name  = "LITELLM_MASTER_KEY"
            value = "password"
          }
          env {
            name  = "DATABASE_URL"
            value = "postgresql://postgres:password@postgres-rw.${kubernetes_namespace.ollama.id}.svc.cluster.local:5432/litellm"
          }
          env {
            name  = "STORE_MODEL_IN_DB"
            value = "True"
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "256Mi"
            }
            limits = {
              memory = "3Gi"
            }
          }

          volume_mount {
            name       = "litellm-config"
            mount_path = "/app/config.yaml"
            sub_path   = "config.yaml"
          }
        }

        volume {
          name = "litellm-config"

          config_map {
            name = kubernetes_config_map.litellm_config.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "litellm" {
  metadata {
    name      = "litellm-service"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "litellm"
    }
  }

  spec {
    selector = {
      app = "litellm"
    }

    port {
      protocol    = "TCP"
      port        = 4000 # Cluster-IP port
      target_port = 4000 # Container port
    }
  }
}

resource "kubernetes_ingress_v1" "litellm_ingress" {
  metadata {
    name      = "litellm-ingress"
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
              name = kubernetes_service.litellm.metadata.0.name
              port {
                number = 4000
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
