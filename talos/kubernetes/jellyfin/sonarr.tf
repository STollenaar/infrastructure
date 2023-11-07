
resource "kubernetes_deployment" "sonarr" {
  metadata {
    name      = "sonarr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "sonarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "sonarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "sonarr"
        }
      }

      spec {
        security_context {
          fs_group = 1000
        }
        container {
          image = "lscr.io/linuxserver/sonarr:latest"
          name  = "sonarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.sonarr_env.metadata.0.name
            }
          }
          port {
            container_port = 8989
          }
          volume_mount {
            name       = "config"
            mount_path = "/config/config.xml"
            sub_path   = "config.xml"
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "tv"
            mount_path = "/tv"
          }
          volume_mount {
            name       = "import"
            mount_path = "/import"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.sonarr_cm.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sonarr_data.metadata.0.name
          }
        }
        volume {
          name = "tv"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_shows.metadata.0.name
          }
        }
        volume {
          name = "import"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sonarr_import.metadata.0.name
          }
        }
        volume {
          name = "downloads"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.downloads.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "sonarr_data" {
  metadata {
    name      = "sonarr-data"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
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

resource "kubernetes_persistent_volume_claim" "sonarr_import" {
  metadata {
    name      = "sonarr-import"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "nfs-client"
    resources {
      requests = {
        storage = "50Gi"
      }
    }
  }
}

resource "kubernetes_service" "sonarr" {
  metadata {
    name      = "sonarr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "sonarr"
    }
    port {
      port = 8989
    }
  }
  depends_on = [
    kubernetes_deployment.sonarr
  ]
}

resource "kubernetes_config_map" "sonarr_env" {
  metadata {
    name      = "sonarr-env"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "TZ"   = local.timezone
    "PUID" = 1000
    "PGID" = 1000
  }
}

resource "kubernetes_config_map" "sonarr_cm" {
  metadata {
    name      = "sonarr-config"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "config.xml" = templatefile("${path.module}/conf/sonarr_config.xml", {})
  }
}
