resource "kubernetes_deployment" "prowlarr" {
  depends_on = [kubernetes_job_v1.prowlarr_init]
  metadata {
    name      = "prowlarr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "prowlarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "prowlarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "prowlarr"
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
          image = "lscr.io/linuxserver/prowlarr:1.37.0"
          name  = "prowlarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.prowlarr_env.metadata.0.name
            }
          }
          port {
            container_port = 9696
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.prowlarr_cm.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.prowlarr_data.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_persistent_volume_claim" "prowlarr_data" {
  metadata {
    name      = "prowlarr-data"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_service" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "prowlarr"
    }
    port {
      port = 9696
    }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}

resource "kubernetes_config_map" "prowlarr_env" {
  metadata {
    name      = "prowlarr-env"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "PUID" = 1000
    "PGID" = 1000
    "TZ"   = local.timezone
  }
}

resource "kubernetes_config_map" "prowlarr_cm" {
  metadata {
    name      = "prowlarr-config"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "config.xml" = templatefile("${path.module}/conf/prowlarr_config.xml", {
      postgres_host = "postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local"
    })
  }
}

resource "kubernetes_job_v1" "prowlarr_init" {
  depends_on = [kubernetes_manifest.cnpg_cluster]
  metadata {
    name      = "prowlarr-init"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "prowlarr"
    }
  }
  spec {
    template {
      metadata {
        labels = {
          app = "prowlarr-init"
        }
      }
      spec {
        container {
          name    = "prowlarr-main"
          image   = "postgres:16.11-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'prowlarr-main'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres prowlarr-main"
          ]
          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
        container {
          name    = "prowlarr-logs"
          image   = "postgres:16.11-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'prowlarr-logs'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres prowlarr-logs"
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

resource "kubernetes_ingress_v1" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "prowlarr.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.prowlarr.metadata.0.name
              port {
                number = 9696
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "prowlarr.home.spicedelver.me"
      ]
      secret_name = "prowlarr-tls"
    }
  }
}
