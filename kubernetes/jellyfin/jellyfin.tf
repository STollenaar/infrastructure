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
    namespace = kubernetes_namespace.jellyfin.id
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
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/worker"
                  operator = "In"
                  values = [
                    "hard-worker"
                  ]
                }
              }
            }
          }
        }
        security_context {
          fs_group = 1000
        }
        runtime_class_name = "nvidia"
        container {
          image = "jellyfin/jellyfin:10.11.0"
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
            name       = "cache"
            mount_path = "/config/cache"
          }
          volume_mount {
            name       = "config"
            mount_path = "/config/config"
          }
          volume_mount {
            name       = "data"
            mount_path = "/config/data"
          }
          volume_mount {
            name       = "log"
            mount_path = "/config/log"
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
          name = "cache"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_cache.metadata.0.name
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_config.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_data.metadata.0.name
          }
        }
        volume {
          name = "log"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_log.metadata.0.name
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
        volume {
          name = "system"
          config_map {
            name = kubernetes_config_map.jellyfin_restore_db.metadata.0.name
            items {
              key  = "system.xml"
              path = "system.xml"
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_data" {
  metadata {
    name      = "jellyfin-data"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_cache" {
  metadata {
    name      = "jellyfin-cache"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_config" {
  metadata {
    name      = "jellyfin-config"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jellyfin_log" {
  metadata {
    name      = "jellyfin-log"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
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
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-csi-main"
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
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-csi-main"
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
    namespace = kubernetes_namespace.jellyfin.id
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
    namespace = kubernetes_namespace.jellyfin.id
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
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
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
    tls {
      hosts = [
        "jellyfin.home.spicedelver.me"
      ]
      secret_name = "jellyfin-tls"
    }
  }
}

resource "kubernetes_ingress_v1" "jellyfin_public" {
  metadata {
    name      = "jellyfin-public"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"               = "nginx"
      "cert-manager.io/cluster-issuer"            = "letsencrypt-prod"
      "external-dns.alpha.kubernetes.io/hostname" = "jellyfin.spicedelver.me"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "jellyfin.spicedelver.me"
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
    tls {
      hosts = [
        "jellyfin.spicedelver.me"
      ]
      secret_name = "jellyfin-public-tls"
    }
  }
}

resource "kubernetes_config_map" "jellyfin_env" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "PUID"      = 1000
    "PGID"      = 1000
    "LOG_LEVEL" = "debug"
    "TZ"        = local.timezone

    NVIDIA_VISIBLE_DEVICES = "all"
    JELLYFIN_CACHE_DIR = "/config/cache"
    JELLYFIN_CONFIG_DIR = "/config/config"
    JELLYFIN_DATA_DIR = "/config/data"
    JELLYFIN_LOG_DIR = "/config/log"
  }
}

resource "kubernetes_config_map" "jellyfin_restore_db" {
  metadata {
    name      = "jellyfin-restore-db"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "system.xml" = file("${path.module}/conf/jellyfin_system.xml")
  }
}


resource "kubernetes_persistent_volume_claim" "downloads" {
  metadata {
    name      = "media-downloads"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-csi-main"
    resources {
      requests = {
        storage = "800Gi"
      }
    }
  }
}
