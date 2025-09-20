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
          fs_group    = 999
          run_as_user = 999
        }
        container {
          name  = "postgres"
          image = "postgres:16.10-bookworm"
          port {
            container_port = 5432
          }
          volume_mount {
            name       = "postgres"
            mount_path = "/var/lib/postgresql/data"
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
            value = "/var/lib/postgresql/data/pgdata"
          }
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
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

resource "kubernetes_manifest" "cnpg_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "postgres"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      instances             = 1
      imageName             = "ghcr.io/cloudnative-pg/postgresql:17"
      primaryUpdateStrategy = "unsupervised"

      superuserSecret = {
        name = kubernetes_secret_v1.postgres_superuser.metadata.0.name
      }
      enableSuperuserAccess = true
      monitoring = {
        enablePodMonitor = true
      }
      bootstrap = {
        initdb = {
          owner    = "admin"
          database = "postgres"
          import = {
            type = "monolith"
            databases = [
              "bazarr-main",
              "prowlarr-logs",
              "prowlarr-main",
              "radarr-logs",
              "radarr-main",
              "sonarr-logs",
              "sonarr-main",
            ]
            source = {
              externalCluster = "jellyfin"
            }
          }
        }
      }
      storage = {
        storageClass = "nfs-csi-main"
        size         = "20Gi"
      }
      externalClusters = [
        {
          name = "jellyfin"
          connectionParameters = {
            host   = "postgres-rw.${kubernetes_namespace.jellyfin.id}"
            user   = "admin"
            dbname = "postgres"
          }
          password = {
            name = kubernetes_secret_v1.postgres_superuser.metadata.0.name
            key  = "password"
          }
        }
      ]
    }
  }
}

resource "kubernetes_secret_v1" "postgres_superuser" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.jellyfin.id
  }

  type = "Opaque"

  data = {
    username = "postgres"
    password = "password"
  }
}
