
resource "kubernetes_deployment" "bazarr" {
  metadata {
    name      = "bazarr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      app = "bazarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "bazarr"
      }
    }

    template {
      metadata {
        labels = {
          app = "bazarr"
        }
      }

      spec {
        container {
          name  = "bazarr"
          image = "ghcr.io/linuxserver/bazarr:1.5.4"

          port {
            container_port = 6767
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.bazarr_env.metadata.0.name
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "movies"
            mount_path = "/media/movies"
          }

          volume_mount {
            name       = "shows"
            mount_path = "/media/shows"
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.bazarr_config.metadata.0.name
          }
        }

        volume {
          name = "movies"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_movies.metadata.0.name
          }
        }

        volume {
          name = "shows"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_shows.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_config_map" "bazarr_env" {
  metadata {
    name      = "bazarr-env"
    namespace = kubernetes_namespace.jellyfin.id
  }

  data = {
    PUID              = "1000"
    PGID              = "1000"
    TZ                = "UTC"
    POSTGRES_ENABLED  = "true"
    POSTGRES_HOST     = "postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local"
    POSTGRES_PORT     = "5432"
    POSTGRES_DATABASE = "bazarr-main"
    POSTGRES_USERNAME = "postgres"
    POSTGRES_PASSWORD = "password"
  }
}


resource "kubernetes_job_v1" "bazarr_init" {
  depends_on = [kubernetes_manifest.cnpg_cluster]
  metadata {
    name      = "bazarr-init"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "bazarr"
    }
  }
  spec {
    template {
      metadata {
        labels = {
          app = "bazarr-init"
        }
      }
      spec {
        container {
          name    = "bazarr-main"
          image   = "postgres:18.6-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'bazarr-main'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres bazarr-main"
          ]
          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.image
    ]
  }
}

resource "kubernetes_persistent_volume_claim" "bazarr_config" {
  metadata {
    name      = "bazarr-config"
    namespace = kubernetes_namespace.jellyfin.id
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_service" "bazarr" {
  metadata {
    name      = "bazarr"
    namespace = kubernetes_namespace.jellyfin.id
  }

  spec {
    selector = {
      app = kubernetes_deployment.bazarr.metadata.0.labels.app
    }

    port {
      port = 6767
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "bazarr_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "bazarr"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "bazarr.home.spicedelver.me"
      tls = {
        secret = "bazarr-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "bazarr"
        service = kubernetes_service.bazarr.metadata.0.name
        port    = 6767
      }]
      routes = [{
        path = "/"
        action = {
          pass = "bazarr"
        }
      }]
    }
  }
}
