
resource "kubernetes_deployment" "qbittorrent" {
  metadata {
    name      = "qbittorrent"
    namespace = kubernetes_namespace.jellyfin.id
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
        # init_container {
        #   name  = "init-qbittorrent"
        #   image = "busybox:1.37.0"
        #   args = [
        #     "/bin/sh",
        #     "-c",
        #     file("${path.module}/conf/copyConfig.sh")
        #   ]
        #   env {
        #     name  = "DESTINATION"
        #     value = "/config/qBittorrent/qBittorrent.conf"
        #   }
        #   env {
        #     name  = "SOURCE"
        #     value = "/tmp/qBittorrent.conf"
        #   }

        #   volume_mount {
        #     name       = "qbit-data"
        #     mount_path = "/config"
        #   }

        #   volume_mount {
        #     name       = "config"
        #     mount_path = "/tmp/qBittorrent.conf"
        #     sub_path   = "qBittorrent.conf"
        #   }
        # }
        container {
          image = "ghcr.io/qdm12/gluetun:v3.41"
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
              name = kubernetes_secret.surfshark.metadata.0.name
            }
          }
          env {
            name = "DNS_ADDRESS"
            value = "194.169.169.169"
          }
          env {
            name  = "WIREGUARD_ADDRESSES"
            value = "10.14.0.2/16"
          }
          env {
            name  = "VPN_TYPE"
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
          image = "linuxserver/qbittorrent:20.04.1"
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
    namespace = kubernetes_namespace.jellyfin.id
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

resource "kubernetes_config_map" "qbittorrent_env" {
  metadata {
    name      = "qbittorrent-env"
    namespace = kubernetes_namespace.jellyfin.id
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
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "qBittorrent.conf" = file("${path.module}/conf/qbittorrent.conf")
  }
}

resource "kubernetes_persistent_volume_claim" "qbit_data" {
  metadata {
    name      = "qbit-config"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
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
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
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
    tls {
      hosts = [
        "qbittorrent.home.spicedelver.me"
      ]
      secret_name = "qbittorrent-tls"
    }
  }
}

resource "kubernetes_secret" "surfshark" {
  metadata {
    name      = "surfshark-openvpn"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    OPENVPN_PASSWORD      = data.aws_ssm_parameter.surfshark_openvpn_password.value
    OPENVPN_USER          = data.aws_ssm_parameter.surfshark_openvpn_user.value
    WIREGUARD_PRIVATE_KEY = data.aws_ssm_parameter.surfshark_wireguard_private_key.value
    WIREGUARD_PUBLIC      = data.aws_ssm_parameter.surfshark_wireguard_public_key.value
  }
}
