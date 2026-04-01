resource "kubernetes_deployment" "jackett" {
  metadata {
    name      = "jackett"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      app = "jackett"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jackett"
      }
    }

    template {
      metadata {
        labels = {
          app = "jackett"
        }
      }

      spec {
        container {
          name  = "jackett"
          image = "ghcr.io/linuxserver/jackett:0.24.1519"

          port {
            container_port = 9117
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.jackett_env.metadata.0.name
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jackett_config.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_config_map" "jackett_env" {
  metadata {
    name      = "jackett-env"
    namespace = kubernetes_namespace.jellyfin.id
  }

  data = {
    PUID = "1000"
    PGID = "1000"
    TZ   = local.timezone
  }
}

resource "kubernetes_persistent_volume_claim" "jackett_config" {
  metadata {
    name      = "jackett-config"
    namespace = kubernetes_namespace.jellyfin.id
  }

  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_service" "jackett" {
  metadata {
    name      = "jackett"
    namespace = kubernetes_namespace.jellyfin.id
  }

  spec {
    selector = {
      app = kubernetes_deployment.jackett.metadata.0.labels.app
    }

    port {
      port = 9117
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "jackett" {
  metadata {
    name      = "jackett"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "jackett.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.jackett.metadata.0.name
              port {
                number = 9117
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "jackett.home.spicedelver.me"
      ]
      secret_name = "jackett-tls"
    }
  }
}
