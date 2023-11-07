resource "kubernetes_deployment" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "jellyseerr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "jellyseerr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "jellyseerr"
        }
      }

      spec {
        container {
          image = "fallenbagel/jellyseerr:latest"
          name  = "jellyseerr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.jellyseerr.metadata.0.name
            }
          }
          port {
            container_port = 5055
            name           = "http"
          }
          volume_mount {
            name       = "data"
            mount_path = "/app/config"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyseerr_data.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jellyseerr_data" {
  metadata {
    name      = "jellyseerr-data"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "15Gi"
      }
    }
  }
}

resource "kubernetes_service" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "jellyseerr"
    }
    port {
      name        = "http"
      port        = 5055
      target_port = "http"
    }
  }
  depends_on = [
    kubernetes_deployment.jellyseerr
  ]
}

resource "kubernetes_config_map" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "LOG_LEVEL" = "debug"
    "TZ"        = local.timezone
  }
}
