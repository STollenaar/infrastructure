resource "kubernetes_deployment" "sonarr" {
  depends_on = [kubernetes_job_v1.sonarr_init]
  metadata {
    name      = "sonarr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "sonarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "sonarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "sonarr"
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
          image = "lscr.io/linuxserver/sonarr:4.0.15"
          name  = "sonarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.sonarr_env.metadata.0.name
            }
          }
          port {
            container_port = 8989
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "tv"
            mount_path = "/tv"
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
            name = kubernetes_config_map.sonarr_cm.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sonarr_data.metadata.0.name
          }
        }
        volume {
          name = "tv"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_shows.metadata.0.name
          }
        }
        volume {
          name = "import"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sonarr_import.metadata.0.name
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

resource "kubernetes_persistent_volume_claim" "sonarr_data" {
  metadata {
    name      = "sonarr-data"
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

resource "kubernetes_persistent_volume_claim" "sonarr_import" {
  metadata {
    name      = "sonarr-import"
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

resource "kubernetes_service" "sonarr" {
  metadata {
    name      = "sonarr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "sonarr"
    }
    port {
      port = 8989
    }
  }
  depends_on = [
    kubernetes_deployment.sonarr
  ]
}

resource "kubernetes_config_map" "sonarr_env" {
  metadata {
    name      = "sonarr-env"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "TZ"   = local.timezone
    "PUID" = 1000
    "PGID" = 1000
  }
}

resource "kubernetes_config_map" "sonarr_cm" {
  metadata {
    name      = "sonarr-config"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "config.xml" = templatefile("${path.module}/conf/sonarr_config.xml", {
      postgres_host = "postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local"
    })
  }
}


resource "kubernetes_job_v1" "sonarr_init" {
  depends_on = [kubernetes_manifest.cnpg_cluster]
  metadata {
    name      = "sonarr-init"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "sonarr"
    }
  }
  spec {
    template {
      metadata {
        labels = {
          app = "sonarr-init"
        }
      }
      spec {
        container {
          name    = "sonarr-main"
          image   = "postgres:18.0-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'sonarr-main'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres sonarr-main"
          ]
          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
        container {
          name    = "sonarr-logs"
          image   = "postgres:18.0-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'sonarr-logs'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres sonarr-logs"
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


resource "kubernetes_ingress_v1" "sonarr" {
  metadata {
    name      = "sonarr"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "sonarr.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.sonarr.metadata.0.name
              port {
                number = 8989
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "sonarr.home.spicedelver.me"
      ]
      secret_name = "sonarr-tls"
    }
  }
}
