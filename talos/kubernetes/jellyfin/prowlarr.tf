resource "kubernetes_deployment" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "prowlarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "prowlarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "prowlarr"
        }
      }

      spec {
        container {
          image = "lscr.io/linuxserver/prowlarr:develop"
          name  = "prowlarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.prowlarr_env.metadata.0.name
            }
          }
          port {
            container_port = 9696
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "prowlarr-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "prowlarr_data" {
  metadata {
    name      = "prowlarr-data"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_service" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "prowlarr"
    }
    port {
      port = 9696
    }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}

resource "kubernetes_config_map" "prowlarr_env" {
  metadata {
    name      = "prowlarr-env"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "PUID" = 1000
    "PGID" = 1000
    "TZ"   = local.timezone
  }
}
