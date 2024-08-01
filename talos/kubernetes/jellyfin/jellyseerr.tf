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
        # init_container {
        #   image = "keinos/sqlite3:latest"
        #   name  = "init-jellyseer"
        #   args = [
        #     "/bin/sh",
        #     "-c",
        #     file("${path.module}/conf/restoreDB.sh")
        #   ]
        #   env {
        #     name  = "DB_PATH"
        #     value = "/config/db"
        #   }
        #   env {
        #     name  = "SETTINGS_PATH"
        #     value = "/config"
        #   }
        #   env {
        #     name  = "SETTINGS_FILE"
        #     value = "settings.json"
        #   }
        #   env {
        #     name  = "DB_NAME"
        #     value = "db.sqlite3"
        #   }
        #   volume_mount {
        #     name       = "data"
        #     mount_path = "/config"
        #   }
        #   volume_mount {
        #     name       = "restore"
        #     mount_path = "/tmp/restore.sql"
        #     sub_path   = "restore.sql"
        #   }
        #   volume_mount {
        #     name       = "settings"
        #     mount_path = "/tmp/settings.json"
        #     sub_path   = "settings.json"
        #   }
        # }
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
        volume {
          name = "restore"
          config_map {
            name = kubernetes_config_map.jellyseer_restore_db.metadata.0.name
            items {
              key  = "restore.sql"
              path = "restore.sql"
            }
          }
        }
        volume {
          name = "settings"
          config_map {
            name = kubernetes_config_map.jellyseer_restore_db.metadata.0.name
            items {
              key  = "settings.json"
              path = "settings.json"
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

resource "kubernetes_persistent_volume_claim" "jellyseerr_data" {
  metadata {
    name      = "jellyseerr-data"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    storage_class_name = "nfs-csi-other"
    access_modes       = ["ReadWriteOnce"]
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


resource "kubernetes_ingress_v1" "jellyseer" {
  metadata {
    name      = "jellyseer"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      #   "cert-manager.io/cluster-issuer" = local.letsencrypt_type
    }
  }
  spec {
    rule {
      host = "jellyseer.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.jellyseerr.metadata.0.name
              port {
                number = 5055
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

resource "kubernetes_config_map" "jellyseer_restore_db" {
  metadata {
    name      = "jellyseer-restore-db"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "restore.sql"   = file("${path.module}/conf/jellyseer.sql")
    "settings.json" = file("${path.module}/conf/jellyseer_settings.json")
  }
}
