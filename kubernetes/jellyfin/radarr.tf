resource "kubernetes_deployment" "radarr" {
  depends_on = [kubernetes_job_v1.radarr_init]
  metadata {
    name      = "radarr"
    namespace = kubernetes_namespace.jellyfin.id
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
          name  = "init-config"
          image = "busybox:1.36.1"
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
          image = "lscr.io/linuxserver/radarr:5.17.2"
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

resource "kubernetes_persistent_volume_claim" "radarr_import" {
  metadata {
    name      = "radarr-import-movies"
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

resource "kubernetes_service" "radarr" {
  metadata {
    name      = "radarr"
    namespace = kubernetes_namespace.jellyfin.id
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
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "TZ"   = local.timezone
    "PUID" = 1000
    "PGID" = 1000
  }
}

resource "kubernetes_config_map" "radarr_cm" {
  metadata {
    name      = "radarr-config"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "config.xml" = templatefile("${path.module}/conf/radarr_config.xml", {
      postgres_host = "${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local"
    })
  }
}


resource "kubernetes_job_v1" "radarr_init" {
  depends_on = [kubernetes_stateful_set_v1.postgres]
  metadata {
    name      = "radarr-init"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "radarr"
    }
  }
  spec {
    template {
      metadata {
        labels = {
          app = "radarr-init"
        }
      }
      spec {
        container {
          name    = "radarr-main"
          image   = "bitnami/postgresql:latest"
          command = ["createdb"]
          args = [
            "-h",
            "${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local",
            "-U",
            "admin",
            "radarr-main"
          ]

          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
        container {
          name    = "radarr-logs"
          image   = "bitnami/postgresql:latest"
          command = ["createdb"]
          args = [
            "-h",
            "${kubernetes_service.postgres.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local",
            "-U",
            "admin",
            "radarr-logs"
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


resource "kubernetes_ingress_v1" "radarr" {
  metadata {
    name      = "radarr"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "radarr.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.radarr.metadata.0.name
              port {
                number = 7878
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "radarr.home.spicedelver.me"
      ]
      secret_name = "radarr-tls"
    }
  }
}
