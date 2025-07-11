resource "kubernetes_stateful_set_v1" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }
        container {
          name  = "postgres"
          image = "bitnami/postgresql:16.6.0-debian-12-r2"
          port {
            container_port = 5432
          }
          volume_mount {
            name       = "postgres"
            mount_path = "/bitnami/postgresql/data"
          }
          env {
            name  = "POSTGRES_USER"
            value = "admin"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
          env {
            name  = "POSTGRESQL_DATA_DIR"
            value = "/bitnami/postgresql/data/pgdata"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "nfs-csi-main"
        resources {
          requests = {
            storage = "20Gi"
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}
