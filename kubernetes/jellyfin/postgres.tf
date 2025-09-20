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
