resource "kubernetes_deployment" "tdarr" {
  #   depends_on = [kubernetes_job_v1.tdarr_init]
  metadata {
    name      = "tdarr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "tdarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "tdarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "tdarr"
        }
      }

      spec {
        # init_container {
        #   name  = "init-config"
        #   image = "busybox:1.37.0"
        #   args = [
        #     "/bin/sh",
        #     "-c",
        #     file("${path.module}/conf/copyConfig.sh")
        #   ]
        #   env {
        #     name  = "DESTINATION"
        #     value = "/config/config.xml"
        #   }
        #   env {
        #     name  = "SOURCE"
        #     value = "/tmp/config.xml"
        #   }
        #   volume_mount {
        #     name       = "config"
        #     mount_path = "/tmp/config.xml"
        #     sub_path   = "config.xml"
        #   }
        #   volume_mount {
        #     name       = "data"
        #     mount_path = "/config"
        #   }
        # }
        container {
          image = "ghcr.io/haveagitgat/tdarr:latest"
          name  = "tdarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.tdarr_env.metadata.0.name
            }
          }
          port {
            container_port = 8266
          }
          port {
            container_port = 8265
          }
          volume_mount {
            name       = "servers"
            mount_path = "/app/server"
          }
          volume_mount {
            name       = "configs"
            mount_path = "/app/configs"
          }
          volume_mount {
            name       = "logs"
            mount_path = "/app/logs"
          }
          volume_mount {
            name       = "cache"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = "tv"
            mount_path = "/media/tv"
          }
          volume_mount {
            name       = "movies"
            mount_path = "/media/movies"
          }
        }
        volume {
          name = "servers"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.tdarr_data.metadata.0.name
          }
        }
        volume {
          name = "tv"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_shows.metadata.0.name
          }
        }
        volume {
          name = "movies"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_movies.metadata.0.name
          }
        }
        volume {
          name = "logs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.tdarr_logs.metadata.0.name
          }
        }
        volume {
          name = "configs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.tdarr_configs.metadata.0.name
          }
        }
        volume {
          name = "cache"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.tdarr_cache.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_persistent_volume_claim" "tdarr_data" {
  metadata {
    name      = "tdarr-server"
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

resource "kubernetes_persistent_volume_claim" "tdarr_logs" {
  metadata {
    name      = "tdarr-logs"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-csi-main"
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "tdarr_configs" {
  metadata {
    name      = "tdarr-configs"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-csi-main"
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "tdarr_cache" {
  metadata {
    name      = "tdarr-cache"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-csi-main"
    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }
}

resource "kubernetes_service" "tdarr" {
  metadata {
    name      = "tdarr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "tdarr"
    }
    port {
      port = 8266
      name = "server"
    }
    port {
      port = 8265
      name = "ui"
    }
  }
  depends_on = [
    kubernetes_deployment.tdarr
  ]
}

resource "kubernetes_config_map" "tdarr_env" {
  metadata {
    name      = "tdarr-env"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "TZ"   = local.timezone
    "PUID" = 1000
    "PGID" = 1000

    UMASK_SET     = "002"
    serverIP      = "0.0.0.0"
    serverPort    = 8266
    webUIPort     = 8265
    internalNode  = true
    inContainer   = true
    ffmpegVersion = 7
    nodeName      = "MyInternalNode"
    auth          = false
    openBrowser   = true
    maxLogSizeMB  = 10
    #   cronPluginUpdate = 
    NVIDIA_DRIVER_CAPABILITIES = "all"
    NVIDIA_VISIBLE_DEVICES     = "all"
  }
}

# resource "kubernetes_config_map" "tdarr_cm" {
#   metadata {
#     name      = "tdarr-config"
#     namespace = kubernetes_namespace.jellyfin.id
#   }
#   data = {
#     "config.xml" = templatefile("${path.module}/conf/tdarr_config.xml", {
#       postgres_host = "${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local"
#     })
#   }
# }

# resource "kubernetes_job_v1" "tdarr_init" {
#   depends_on = [kubernetes_stateful_set_v1.postgres]
#   metadata {
#     name      = "tdarr-init"
#     namespace = kubernetes_namespace.jellyfin.id
#     labels = {
#       "app" = "tdarr"
#     }
#   }
#   spec {
#     template {
#       metadata {
#         labels = {
#           app = "tdarr-init"
#         }
#       }
#       spec {
#         container {
#           name    = "tdarr-main"
#           image   = "postgres:16.10-bookworm"
#           command = ["/bin/sh", "-c"]
#           args = [
#             "psql -h ${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U admin postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'tdarr-main'\" | grep -q 1 || createdb -h ${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U admin tdarr-main"
#           ]
#           env {
#             name  = "PGPASSWORD"
#             value = "password"
#           }
#         }
#         container {
#           name    = "tdarr-logs"
#           image   = "postgres:16.10-bookworm"
#           command = ["/bin/sh", "-c"]
#           args = [
#             "psql -h ${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U admin postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'tdarr-logs'\" | grep -q 1 || createdb -h ${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U admin tdarr-logs"
#           ]
#           env {
#             name  = "PGPASSWORD"
#             value = "password"
#           }
#         }
#       }
#     }
#   }
# }


resource "kubernetes_ingress_v1" "tdarr" {
  metadata {
    name      = "tdarr"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "tdarr.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.tdarr.metadata.0.name
              port {
                number = 8265
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "tdarr.home.spicedelver.me"
      ]
      secret_name = "tdarr-tls"
    }
  }
}
