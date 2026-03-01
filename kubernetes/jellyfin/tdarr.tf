resource "kubernetes_deployment" "tdarr" {
  #   depends_on = [kubernetes_job_v1.tdarr_init]
  metadata {
    name      = "tdarr-server"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "tdarr-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "tdarr-server"
      }
    }

    template {
      metadata {
        annotations = {
          "configmap-hash" = sha256(jsonencode(kubernetes_config_map.tdarr_server_env.data))
        }
        labels = {
          "app" = "tdarr-server"
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
        runtime_class_name = "nvidia"

        container {
          image = "ghcr.io/haveagitgat/tdarr:2.59.01"
          name  = "tdarr-server"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.tdarr_server_env.metadata.0.name
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

resource "kubernetes_deployment" "tdarr_node" {
  #   depends_on = [kubernetes_job_v1.tdarr_init]
  metadata {
    name      = "tdarr-node"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "tdarr-node"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "tdarr-node"
      }
    }

    template {
      metadata {
        annotations = {
          "configmap-hash" = sha256(jsonencode(kubernetes_config_map.tdarr_node_env.data))
        }
        labels = {
          "app" = "tdarr-node"
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app"
                  operator = "In"
                  values = [
                    "tdarr-server"
                  ]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        container {
          image = "ghcr.io/haveagitgat/tdarr_node:2.59.01"
          name  = "tdarr-node"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.tdarr_node_env.metadata.0.name
            }
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
    name      = "tdarr-server"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "tdarr-server"
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

resource "kubernetes_config_map" "tdarr_server_env" {
  metadata {
    name      = "tdarr-server-env"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "TZ"   = local.timezone
    "PUID" = 1000
    "PGID" = 1000

    UMASK_SET                  = "002"
    serverIP                   = "0.0.0.0"
    serverPort                 = 8266
    webUIPort                  = 8265
    internalNode               = true
    inContainer                = true
    ffmpegVersion              = 7
    nodeName                   = "MainNode"
    auth                       = false
    openBrowser                = true
    startPaused                = true
    maxLogSizeMB               = 10
    transcodegpuWorkers        = 0
    transcodecpuWorkers        = 1
    healthcheckgpuWorkers      = 0
    healthcheckcpuWorkers      = 0
    NVIDIA_DRIVER_CAPABILITIES = "all"
    NVIDIA_VISIBLE_DEVICES     = "all"
  }
}

resource "kubernetes_config_map" "tdarr_node_env" {
  metadata {
    name      = "tdarr-node-env"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "TZ"                  = local.timezone
    "PUID"                = 1000
    "PGID"                = 1000
    UMASK_SET             = "002"
    nodeName              = "ExternalNode"
    serverURL             = "http://${kubernetes_service.tdarr.metadata.0.name}.${kubernetes_namespace.jellyfin.id}:8266"
    serverPort            = 8266
    inContainer           = true
    ffmpegVersion         = 7
    nodeType              = "mapped"
    priority              = -1
    maxLogSizeMB          = 10
    pollInterval          = 2000
    startPaused           = true
    transcodegpuWorkers   = 0
    transcodecpuWorkers   = 1
    healthcheckgpuWorkers = 0
    healthcheckcpuWorkers = 0
  }
}

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
