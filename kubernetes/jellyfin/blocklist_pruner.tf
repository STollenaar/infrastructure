# Stall handling with an expiring blocklist.
#
# decluttarr owns the "invalid media format" side (remove_bad_files /
# remove_failed_imports) and those blocks stay permanent on purpose - a fake release
# should never come back. This job owns the stall side instead, because decluttarr
# v2.2.0 can express neither half of "stalled for 3 days, blocked for 18":
#   - max_strikes counts job cycles, held in an in-memory dict that resets on restart
#     or whenever the queue empties, so a multi-day threshold never reliably lands.
#   - RemoveStalled hardcodes blocklist = True and *arr blocklist rows have no expiry.
#
# It has to do the removal itself to know which blocks are its own: Sonarr and Radarr
# stamp every queue-delete-with-blocklist as "Manually marked as failed" regardless of
# cause, so a blocklist row carries nothing that says why it is there. The job records
# the ids it creates and only ever expires those. See conf/blocklist-pruner.py.
#
# remove_stalled is disabled in declutarr.tf to keep the two from overlapping; a
# decluttarr-created stall block would be indistinguishable from a bad-format one and
# would therefore never expire.

resource "kubernetes_cron_job_v1" "blocklist_pruner" {
  metadata {
    name      = "blocklist-pruner"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      app = "blocklist-pruner"
    }
  }

  spec {
    # Daily is plenty: both thresholds are measured in days, and the stall clock
    # comes from qBittorrent's last_activity, so nothing is lost between runs.
    schedule                      = "17 4 * * *"
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 3
    successful_jobs_history_limit = 1
    starting_deadline_seconds     = 3600

    job_template {
      metadata {
        labels = {
          app = "blocklist-pruner"
        }
      }
      spec {
        backoff_limit = 2
        template {
          metadata {
            labels = {
              app = "blocklist-pruner"
            }
            annotations = {
              "checksum/script" = sha256(file("${path.module}/conf/blocklist-pruner.py"))
            }
          }
          spec {
            restart_policy = "OnFailure"

            container {
              name    = "blocklist-pruner"
              image   = "python:3.13-alpine"
              command = ["python3", "/opt/blocklist-pruner.py"]

              env {
                name  = "TZ"
                value = local.timezone
              }
              # Stalled this long with no activity -> remove + blocklist.
              env {
                name  = "STALL_DAYS"
                value = "3"
              }
              # Blocklist entry is dropped this long after it was created.
              env {
                name  = "BLOCK_DAYS"
                value = "18"
              }
              # Same escape hatch as decluttarr's general.protected_tag.
              env {
                name  = "PROTECTED_TAG"
                value = "Don't Kill"
              }
              env {
                name  = "STATE_FILE"
                value = "/state/blocklist-state.json"
              }

              # Reuses decluttarr's credentials rather than duplicating them.
              env_from {
                secret_ref {
                  name = kubernetes_secret_v1.decluttarr_secrets.metadata[0].name
                }
              }
              env {
                name  = "SONARR_URL"
                value = "http://${kubernetes_service.sonarr.metadata.0.name}:8989"
              }
              env {
                name  = "RADARR_URL"
                value = "http://${kubernetes_service.radarr.metadata.0.name}:7878"
              }
              env {
                name  = "QBITTORRENT_URL"
                value = "http://${kubernetes_service.qbittorrent.metadata.0.name}:8080"
              }

              volume_mount {
                name       = "script"
                mount_path = "/opt/blocklist-pruner.py"
                sub_path   = "blocklist-pruner.py"
                read_only  = true
              }
              volume_mount {
                name       = "state"
                mount_path = "/state"
              }
            }

            volume {
              name = "script"
              config_map {
                name         = kubernetes_config_map_v1.blocklist_pruner_script.metadata[0].name
                default_mode = "0444"
                items {
                  key  = "blocklist-pruner.py"
                  path = "blocklist-pruner.py"
                }
              }
            }
            volume {
              name = "state"
              persistent_volume_claim {
                claim_name = kubernetes_persistent_volume_claim.blocklist_pruner_state.metadata[0].name
              }
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].suspend
    ]
  }
}

resource "kubernetes_config_map_v1" "blocklist_pruner_script" {
  metadata {
    name      = "blocklist-pruner-script"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "blocklist-pruner.py" = file("${path.module}/conf/blocklist-pruner.py")
  }
}

# Holds which blocklist ids this job created, and when. Losing this file does not
# break anything - it only means the blocks pending at that moment stop being
# tracked and stay permanent, the same as a bad-format block.
resource "kubernetes_persistent_volume_claim" "blocklist_pruner_state" {
  metadata {
    name      = "blocklist-pruner-state"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
