
resource "kubernetes_deployment" "qflood" {
  metadata {
    name      = "qflood"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "qflood"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "qflood"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "qflood"
        }
      }

      spec {
        security_context {
          fs_group = 1000
        }
        container {
          image = "ghcr.io/qdm12/gluetun"
          name  = "gluetun"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.qflood_env.metadata.0.name
            }
          }
          env {
            name  = "VPN_SERVICE_PROVIDER"
            value = "surfshark"
          }
          env_from {
            secret_ref {
              name = kubernetes_manifest.surfshark_openvpn_credentials.manifest.spec.destination.name
            }
          }
          env {
            name  = "SERVER_COUNTRIES"
            value = "Netherlands"
          }
          port {
            container_port = 8000
            name           = "gluetunui"
          }
          port {
            container_port = 8388
            name           = "shadowsocks"
          }
          security_context {
            capabilities {
              add = ["NET_ADMIN"]
            }
          }
        }
        container {
          image = "hotio/qbittorrent:release-4.6.0"
          name  = "qflood"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.qflood_env.metadata.0.name
            }
          }
          port {
            container_port = 8080
            name           = "qbittorrent"
          }
          port {
            container_port = 3000
            name           = "floodui"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
          }
          volume_mount {
            name       = "config"
            mount_path = "/app/qBittorrent.conf"
            sub_path   = "qBittorrent.conf"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.qflood_cm.metadata.0.name
            items {
              key  = "qBittorrent.conf"
              path = "qBittorrent.conf"
            }
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
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_service" "qbittorrent" {
  metadata {
    name      = "qbittorrent"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "qflood"
    }
    port {
      name        = "qbittorrent"
      port        = 8080
      target_port = "qbittorrent"
    }
    port {
      name        = "gluetunui"
      port        = 8000
      target_port = "gluetunui"
    }
  }
  depends_on = [
    kubernetes_deployment.qflood
  ]
}

resource "kubernetes_service" "floodui" {
  metadata {
    name      = "floodui"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "qflood"
    }
    port {
      name        = "floodui"
      port        = 3000
      target_port = "floodui"
    }
  }
  depends_on = [
    kubernetes_deployment.qflood
  ]
}

resource "kubernetes_config_map" "qflood_env" {
  metadata {
    name      = "qflood-env"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "PUID"       = 1000
    "PGID"       = 1000
    "TZ"         = local.timezone
    "FLOOD_AUTH" = "true"
  }
}

resource "kubernetes_config_map" "qflood_cm" {
  metadata {
    name      = "qflood-config"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "qBittorrent.conf" = file("${path.module}/conf/qflood.conf")
  }
}
