locals {
  timezone = "America/StJohns"
}

resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = "jellyfin"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_deployment" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "jellyfin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "jellyfin"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "jellyfin"
        }
      }

      spec {
        security_context {
          fs_group = 1000
        }
        container {
          image = "lscr.io/linuxserver/jellyfin:latest"
          name  = "jellyfin"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.jellyfin_env.metadata.0.name
            }
          }
          port {
            name           = "web"
            container_port = 8096
          }
          port {
            name           = "local-discovery"
            container_port = 7359
          }
          port {
            name           = "dlna"
            container_port = 1900
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "movies"
            mount_path = "/data/movies"
          }
          volume_mount {
            name       = "tv"
            mount_path = "/data/tv"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_data.metadata.0.name
          }
        }
        volume {
          name = "movies"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_movies.metadata.0.name
          }
        }
        volume {
          name = "tv"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_shows.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [ spec.0.replicas ]
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_data" {
  metadata {
    name      = "jellyfin-data"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_movies" {
  metadata {
    name      = "jellyfin-data-movies"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-client-movies"
    resources {
      requests = {
        storage = "200Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_shows" {
  metadata {
    name      = "jellyfin-data-shows"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-client-other"
    resources {
      requests = {
        storage = "800Gi"
      }
    }
  }
}

resource "kubernetes_service" "jellyfin_web" {
  metadata {
    name      = "jellyfin-web"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "jellyfin"
    }
    port {
      name        = "web"
      port        = 8096
      target_port = "web"
    }
  }
  depends_on = [
    kubernetes_deployment.jellyfin
  ]
}

resource "kubernetes_service" "jellyfin_discovery" {
  metadata {
    name      = "jellyfin-local-discovery"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "jellyfin"
    }
    port {
      name        = "local-discovery"
      port        = 7359
      target_port = "local-discovery"
    }
    port {
      name        = "dlna"
      port        = 1900
      target_port = "dlna"
    }
  }
}

resource "kubernetes_ingress_v1" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
    #   "cert-manager.io/cluster-issuer" = local.letsencrypt_type
    }
  }
  spec {
    rule {
      host = "jellyfin.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.jellyfin_web.metadata.0.name
              port {
                number = 8096
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

resource "kubernetes_config_map" "jellyfin_env" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "PUID"      = 1000
    "PGID"      = 1000
    "LOG_LEVEL" = "debug"
    "TZ"        = local.timezone
  }
}


resource "kubernetes_persistent_volume_claim" "downloads" {
  metadata {
    name      = "media-downloads"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-client-other"
    resources {
      requests = {
        storage = "800Gi"
      }
    }
  }
}
