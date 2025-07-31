resource "kubernetes_deployment" "whisparr" {
  depends_on = [kubernetes_job_v1.whisparr_init]
  metadata {
    name      = "whisparr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "whisparr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "whisparr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "whisparr"
        }
      }

      spec {
        init_container {
          name  = "init-config"
          image = "busybox:1.37.0"
          args = [
            "/bin/sh",
            "-c",
            file("${path.module}/conf/copyConfig.sh")
          ]
          env {
            name  = "DESTINATION"
            value = "/config/config.xml"
          }
          env {
            name  = "SOURCE"
            value = "/tmp/config.xml"
          }

          volume_mount {
            name       = "config"
            mount_path = "/tmp/config.xml"
            sub_path   = "config.xml"
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
        }
        container {
          image = "ghcr.io/hotio/whisparr:v3-3.0.0.770"
          name  = "whisparr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.whisparr_env.metadata.0.name
            }
          }
          port {
            container_port = 6969
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "shows"
            mount_path = "/shows"
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
            name = kubernetes_config_map.whisparr_cm.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.whisparr_data.metadata.0.name
          }
        }
        volume {
          name = "shows"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.whisparr_shows.metadata.0.name
          }
        }
        volume {
          name = "import"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.whisparr_import.metadata.0.name
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

resource "kubernetes_persistent_volume_claim" "whisparr_data" {
  metadata {
    name      = "whisparr-data"
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

resource "kubernetes_persistent_volume_claim" "whisparr_import" {
  metadata {
    name      = "whisparr-import"
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

resource "kubernetes_persistent_volume_claim" "whisparr_shows" {
  metadata {
    name      = "whisparr-shows"
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

resource "kubernetes_service" "whisparr" {
  metadata {
    name      = "whisparr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "whisparr"
    }
    port {
      port = 6969
    }
  }
  depends_on = [
    kubernetes_deployment.whisparr
  ]
}

resource "kubernetes_config_map" "whisparr_env" {
  metadata {
    name      = "whisparr-env"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "TZ"   = local.timezone
    "PUID" = 0
    "PGID" = 0
  }
}

resource "kubernetes_config_map" "whisparr_cm" {
  metadata {
    name      = "whisparr-config"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "config.xml" = templatefile("${path.module}/conf/whisparr_config.xml", {
      postgres_host = "${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local"
    })
  }
}


resource "kubernetes_job_v1" "whisparr_init" {
  depends_on = [kubernetes_stateful_set_v1.postgres]
  metadata {
    name      = "whisparr-init"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "whisparr"
    }
  }
  spec {
    template {
      metadata {
        labels = {
          app = "whisparr-init"
        }
      }
      spec {
        container {
          name    = "whisparr-main"
          image   = "postgres:16.9-bookworm"
          command = ["createdb"]
          args = [
            "-h",
            "${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local",
            "-U",
            "admin",
            "whisparr-main"
          ]

          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
        container {
          name    = "whisparr-logs"
          image   = "postgres:16.9-bookworm"
          command = ["createdb"]
          args = [
            "-h",
            "${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local",
            "-U",
            "admin",
            "whisparr-logs"
          ]

          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
      }
    }
  }
}
