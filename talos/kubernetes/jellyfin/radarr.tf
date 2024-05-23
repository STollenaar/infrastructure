
resource "kubernetes_deployment" "radarr" {
  metadata {
    name      = "radarr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "radarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "radarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "radarr"
        }
      }

      spec {
        security_context {
          fs_group = 1000
        }
        init_container {
          image = "keinos/sqlite3:latest"
          name  = "init-radarr"
          args = [
            "/bin/sh",
            "-c",
            file("${path.module}/conf/restoreDB.sh")
          ]
          env {
            name  = "DB_PATH"
            value = "/config"
          }
          env {
            name  = "DB_NAME"
            value = "radarr.db"
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "restore"
            mount_path = "/tmp/restore.sql"
            sub_path   = "restore.sql"
          }
        }
        container {
          image = "lscr.io/linuxserver/radarr:4.2.4"
          name  = "radarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.radarr_env.metadata.0.name
            }
          }
          port {
            container_port = 7878
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
            name       = "movies"
            mount_path = "/movies"
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
            name = kubernetes_config_map.radarr_cm.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.radarr_data.metadata.0.name
          }
        }
        volume {
          name = "import"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.radarr_import.metadata.0.name
          }
        }
        volume {
          name = "movies"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_movies.metadata.0.name
          }
        }
        volume {
          name = "downloads"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.downloads.metadata.0.name
          }
        }
        volume {
          name = "restore"
          config_map {
            name = kubernetes_config_map.radarr_restore_db.metadata.0.name
          }
        }

      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_persistent_volume_claim" "radarr_data" {
  metadata {
    name      = "radarr-data"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    storage_class_name = "openebs-hostpath"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "radarr_import" {
  metadata {
    name      = "radarr-import-movies"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-client-other"
    resources {
      requests = {
        storage = "200Gi"
      }
    }
  }
}

resource "kubernetes_service" "radarr" {
  metadata {
    name      = "radarr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "radarr"
    }
    port {
      port = 7878
    }
  }
  depends_on = [
    kubernetes_deployment.radarr
  ]
}

resource "kubernetes_config_map" "radarr_env" {
  metadata {
    name      = "radarr-env"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "TZ"         = local.timezone
    "PUID"       = 1000
    "PGID"       = 1000
    "config.xml" = templatefile("${path.module}/conf/radarr_config.xml", {})
  }
}

resource "kubernetes_config_map" "radarr_cm" {
  metadata {
    name      = "radarr-config"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "config.xml" = templatefile("${path.module}/conf/radarr_config.xml", {})
  }
}

resource "kubernetes_config_map" "radarr_restore_db" {
  metadata {
    name      = "radarr-restore-db"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  data = {
    "restore.sql" = file("${path.module}/conf/radarr.sql")
  }
}
