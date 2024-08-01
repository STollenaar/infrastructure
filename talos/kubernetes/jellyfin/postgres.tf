resource "kubernetes_stateful_set_v1" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
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
        container {
          name  = "postgres"
          image = "bitnami/postgresql:16.3.0-debian-12-r23"
          port {
            container_port = 5432
          }
          volume_mount {
            name       = "postgres"
            mount_path = "/var/lib/postgresql"
          }
          env {
            name  = "POSTGRES_USER"
            value = "admin"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "nfs-csi-other"
        resources {
          requests = {
            storage = "20Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
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
