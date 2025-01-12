
resource "kubernetes_deployment" "qbittorrent" {
  metadata {
    name      = "qbittorrent"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "qbittorrent"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "qbittorrent"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "qbittorrent"
        }
      }

      spec {
        security_context {
          fs_group = 1000
        }
        init_container {
          name  = "init-qbittorrent"
          image = "busybox:1.36.1"
          args = [
            "/bin/sh",
            "-c",
            file("${path.module}/conf/copyConfig.sh")
          ]
          env {
            name  = "DESTINATION"
            value = "/config/config/qBittorrent.conf"
          }
          env {
            name  = "SOURCE"
            value = "/tmp/qBittorrent.conf"
          }

          volume_mount {
            name       = "qbit-data"
            mount_path = "/config"
          }

          volume_mount {
            name       = "config"
            mount_path = "/tmp/qBittorrent.conf"
            sub_path   = "qBittorrent.conf"
          }
        }
        container {
          image = "ghcr.io/qdm12/gluetun:v3.39"
          name  = "gluetun"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.qbittorrent_env.metadata.0.name
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
            name = "WIREGUARD_ADDRESSES"
            value = "10.14.0.2/16"
          }
          env {
            name = "VPN_TYPE"
            value = "openvpn"
          }
          env {
            name  = "SERVER_COUNTRIES"
            value = "Canada"
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
          resources {
            limits = {
              "squat.ai/tun" = "1"
            }
          }
        }
        container {
          image = "hotio/qbittorrent:release-4.6.6"
          name  = "qbittorrent"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.qbittorrent_env.metadata.0.name
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
            name       = "qbit-data"
            mount_path = "/config"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.qbittorrent_cm.metadata.0.name
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
        volume {
          name = "qbit-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.qbit_data.metadata.0.name
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
      "app" = "qbittorrent"
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
    kubernetes_deployment.qbittorrent
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
      "app" = "qbittorrent"
    }
    port {
      name        = "floodui"
      port        = 3000
      target_port = "floodui"
    }
  }
  depends_on = [
    kubernetes_deployment.qbittorrent
  ]
}

resource "kubernetes_config_map" "qbittorrent_env" {
  metadata {
    name      = "qbittorrent-env"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "PUID"       = 1000
    "PGID"       = 1000
    "TZ"         = local.timezone
    "FLOOD_AUTH" = "true"
  }
}

resource "kubernetes_config_map" "qbittorrent_cm" {
  metadata {
    name      = "qbittorrent-config"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "qBittorrent.conf" = file("${path.module}/conf/qbittorrent.conf")
  }
}

resource "kubernetes_persistent_volume_claim" "qbit_data" {
  metadata {
    name      = "qbit-config"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    storage_class_name = "nfs-csi-other"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_ingress_v1" "qbittorrent" {
  metadata {
    name      = "qbittorrent"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      #   "cert-manager.io/cluster-issuer" = local.letsencrypt_type
    }
  }
  spec {
    rule {
      host = "qbittorrent.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.qbittorrent.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
    # tls {
    #   hosts       = [local.domain]
    #   secret_name = local.letsencrypt_type
    # }
  }
}
