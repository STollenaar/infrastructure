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

      # Configure the barman object plugin via the Cluster's plugins array.
      # The operator will load this plugin and use it for WAL archiving/backups.
      backup = {
        barmanObjectStore = {
          destinationPath = "s3://stollenaar-discordbots/jellyfin/postgres"
          # credentialsSecret = kubernetes_secret_v1.postgres_backup.metadata.0.name
          s3Credentials = {
            accessKeyId = {
              name = kubernetes_secret_v1.postgres_backup.metadata.0.name
              key  = "ACCESS_KEY_ID"
            }
            secretAccessKey = {
              name = kubernetes_secret_v1.postgres_backup.metadata.0.name
              key  = "ACCESS_SECRET_KEY"
            }
          }
          endpointURL = "s3.ca-east-006.backblazeb2.com"
          wal = {
            compression = "gzip"
          }
        }
      }
      plugins = [
        {
          name    = "barman-cloud.cloudnative-pg.io"
          enabled = true
          parameters = {
            bucket            = "stollenaar-discordbots"
            region            = "ca-east-006"
            s3ForcePathStyle  = "true"
            credentialsSecret = kubernetes_secret_v1.postgres_backup.metadata.0.name
            endpoint          = "s3.ca-east-006.backblazeb2.com"
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

resource "kubernetes_secret_v1" "postgres_backup" {
  metadata {
    name      = "postgres-backup-credentials"
    namespace = kubernetes_namespace.jellyfin.id
  }

  type = "Opaque"

  data = {
    ACCESS_KEY_ID     = data.aws_ssm_parameter.backblaze_access_key.value
    ACCESS_SECRET_KEY = data.aws_ssm_parameter.backblaze_access_secret_key.value
    ACCESS_REGION     = "ca-east-006"
  }
}


resource "kubernetes_manifest" "postgres_daily_full_backup" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ScheduledBackup"
    metadata = {
      name      = "postgres-daily-full"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      schedule = "0 0 0 * * *" # seconds minutes hours day month weekday -> daily at 03:00
      cluster = {
        name = "postgres"
      }
      method = "plugin"
      pluginConfiguration = {
        name = "barman-cloud.cloudnative-pg.io"
        # parameters = {
        # Plugin-specific overrides can be provided here if needed.
        # }
      }
      immediate = false
      suspend   = false
    }
  }
}
