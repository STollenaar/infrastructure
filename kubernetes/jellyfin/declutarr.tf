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
        annotations = {
          "checksum/config" = sha256(kubernetes_config_map_v1.decluttarr_config.data["config.yaml"])
        }
      }

      spec {
        container {
          name  = "decluttarr"
          image = "ghcr.io/manimatter/decluttarr:v2.1.0"

          env {
            name  = "TZ"
            value = local.timezone
          }
          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.decluttarr_secrets.metadata[0].name
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/config/config.yaml"
            sub_path   = "config.yaml"
          }
          volume_mount {
            name       = "movies"
            mount_path = "/movies"
          }
          volume_mount {
            name       = "tv"
            mount_path = "/tv"
          }


          image_pull_policy = "Always"
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.decluttarr_config.metadata[0].name
          }
        }
        volume {
          name = "movies"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_movies.metadata.0.name
          }
        }
        volume {
          name = "tv"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_shows.metadata.0.name
          }
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
    "config.yaml" = <<-EOT
      general:
        log_level: INFO
        test_run: false
        timer: 10
        ignored_download_clients:
          - emulerr
        protected_tag: "Don't Kill"

      job_defaults:
        max_strikes: 3
        min_days_between_searches: 7
        max_concurrent_searches: 3

      jobs:
        # Marks non-media/sample/unavailable files as "do not download" in qBittorrent;
        # blocklists + removes the torrent when nothing wanted is left (e.g. .exe/.lnk-only fakes)
        remove_bad_files:
          keep_archives: false
        remove_failed_downloads:
        # Blocklists + removes completed downloads the *arrs refuse to import.
        # Patterns are fnmatch (case-sensitive, exact unless wildcards are used).
        # Deliberately excluded (need manual action, not removal): "Unknown Series/Movie",
        # "Unable to parse file", "matched to series by ID", "Not enough free space", TBA titles.
        remove_failed_imports:
          message_patterns:
            # Not an upgrade over what's already on disk
            - "Not a Custom Format upgrade for existing*"
            - "Not an upgrade for existing*"
            - "Not a quality revision upgrade for existing*"
            - "*file already imported at*"
            # Malicious / fake releases
            - "*Found potentially dangerous file with extension*"
            - "*Found executable file with extension*"
            - "Invalid video file*"
            - "No files found are eligible for import*"
            - "No audio tracks detected*"
            - "Sample"
            - "Unable to determine if file is a sample*"
            # Season packs missing episodes (everything importable is already imported)
            - "One or more episodes expected in this release were not imported or missing from the release*"
        remove_metadata_missing:
        remove_missing_files:
        remove_orphans:
        remove_stalled:
          max_strikes: 3
        remove_unmonitored:
        search_unmet_cutoff:
        search_missing:

      instances:
        sonarr:
          - base_url: "http://${kubernetes_service.sonarr.metadata.0.name}:8989"
            api_key: !ENV SONARR_KEY
        radarr:
          - base_url: "http://${kubernetes_service.radarr.metadata.0.name}:7878"
            api_key: !ENV RADARR_KEY

      download_clients:
        qbittorrent:
          - base_url: "http://${kubernetes_service.qbittorrent.metadata.0.name}:8080"
            username: !ENV QBITTORRENT_USERNAME
            password: !ENV QBITTORRENT_PASSWORD
    EOT
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
