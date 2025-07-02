resource "kubernetes_deployment" "decluttarr" {
  metadata {
    name      = "decluttarr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      app = "decluttarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "decluttarr"
      }
    }

    template {
      metadata {
        labels = {
          app = "decluttarr"
        }
      }

      spec {
        container {
          name  = "decluttarr"
          image = "ghcr.io/manimatter/decluttarr:latest"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.decluttarr_config.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.decluttarr_secrets.metadata[0].name
            }
          }

          image_pull_policy = "Always"
        }

        restart_policy = "Always"
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_config_map_v1" "decluttarr_config" {
  metadata {
    name      = "decluttarr-config"
    namespace = kubernetes_namespace.jellyfin.id
  }

  data = {
    "TZ"                           = local.timezone
    PUID                           = "1000"
    PGID                           = "1000"
    LOG_LEVEL                      = "INFO"
    REMOVE_TIMER                   = "10"
    REMOVE_FAILED                  = "True"
    REMOVE_FAILED_IMPORTS          = "True"
    REMOVE_METADATA_MISSING        = "True"
    REMOVE_MISSING_FILES           = "True"
    REMOVE_ORPHANS                 = "True"
    REMOVE_SLOW                    = "True"
    REMOVE_STALLED                 = "True"
    REMOVE_UNMONITORED             = "True"
    RUN_PERIODIC_RESCANS           = <<EOF
{
  "SONARR": {"MISSING": true, "CUTOFF_UNMET": true, "MAX_CONCURRENT_SCANS": 3, "MIN_DAYS_BEFORE_RESCAN": 7},
  "RADARR": {"MISSING": true, "CUTOFF_UNMET": true, "MAX_CONCURRENT_SCANS": 3, "MIN_DAYS_BEFORE_RESCAN": 7}
}
EOF
    PERMITTED_ATTEMPTS             = "3"
    NO_STALLED_REMOVAL_QBIT_TAG    = "Don't Kill"
    MIN_DOWNLOAD_SPEED             = "100"
    FAILED_IMPORT_MESSAGE_PATTERNS = <<EOF
[
  "Not a Custom Format upgrade for existing",
  "Not an upgrade for existing"
]
EOF
    IGNORED_DOWNLOAD_CLIENTS       = "[\"emulerr\"]"

    RADARR_URL      = "http://${kubernetes_service.radarr.metadata.0.name}:7878"
    SONARR_URL      = "http://${kubernetes_service.sonarr.metadata.0.name}:8989"
    QBITTORRENT_URL = "http://${kubernetes_service.qbittorrent.metadata.0.name}:8080"
  }
}

resource "kubernetes_secret_v1" "decluttarr_secrets" {
  metadata {
    name      = "decluttarr-secrets"
    namespace = kubernetes_namespace.jellyfin.id
  }

  # TODO: Fix
  data = {
    RADARR_KEY           = "2a5a773b3637437394c29ae7a58ea311"
    SONARR_KEY           = "12f9f7355eb74ec0956077c054bc9145"
    QBITTORRENT_USERNAME = "admin"
    QBITTORRENT_PASSWORD = "vjd_puz7dwg4QKX@uzk"
  }
}
