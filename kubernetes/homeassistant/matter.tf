
resource "kubernetes_deployment_v1" "matter" {
  metadata {
    name      = "matter"
    namespace = kubernetes_namespace_v1.homeassistant.id
    labels = {
      app = "matter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "matter"
      }
    }

    template {
      metadata {
        labels = {
          app = "matter"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/hostname"
                  operator = "In"
                  values   = ["talos-iso-cgi"]
                }
              }
            }
          }
        }

        container {
          name  = "matter"
          image = "ghcr.io/matter-js/python-matter-server:8.1.2"

          port {
            container_port = 5580
          }

          security_context {
            privileged = true
          }
          volume_mount {
            name       = "matter-data"
            mount_path = "/data"
          }
        }
        host_network = true

        volume {
          name = "matter-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.matter_data.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "matter" {
  metadata {
    name      = "matter"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  spec {
    selector = {
      app = "matter"
    }

    port {
      port        = 5580
      target_port = 5580
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "matter_data" {
  metadata {
    name      = "matter-data"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_cron_job_v1" "matter_backup" {
  metadata {
    name      = "matter-backup"
    namespace = kubernetes_namespace_v1.homeassistant.id
    labels = {
      app = "matter-backup"
    }
  }

  spec {
    schedule                      = "0 6 * * *"
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 3
    successful_jobs_history_limit = 1

    job_template {
      metadata {
        labels = {
          app = "matter-backup"
        }
      }

      spec {
        backoff_limit = 2

        template {
          metadata {
            labels = {
              app = "matter-backup"
            }
          }

          spec {
            restart_policy = "OnFailure"

            affinity {
              node_affinity {
                required_during_scheduling_ignored_during_execution {
                  node_selector_term {
                    match_expressions {
                      key      = "kubernetes.io/hostname"
                      operator = "In"
                      values   = ["talos-iso-cgi"]
                    }
                  }
                }
              }
            }

            container {
              name  = "matter-backup"
              image = "alpine:3.22"

              command = ["/bin/sh", "-c", <<-EOT
                set -eu
                dest=/config/matter-backups
                tmp="$dest/.matter-data.tar.gz.tmp"
                mkdir -p "$dest"
                trap 'rm -f "$tmp"' EXIT
                tar -czf "$tmp" -C /matter-data .
                mv "$tmp" "$dest/matter-data.tar.gz"
                echo "wrote $(stat -c %s "$dest/matter-data.tar.gz") bytes"
              EOT
              ]

              volume_mount {
                name       = "matter-data"
                mount_path = "/matter-data"
                read_only  = true
              }

              volume_mount {
                name       = "config"
                mount_path = "/config"
              }
            }

            volume {
              name = "matter-data"
              persistent_volume_claim {
                claim_name = kubernetes_persistent_volume_claim_v1.matter_data.metadata[0].name
              }
            }

            volume {
              name = "config"
              persistent_volume_claim {
                claim_name = kubernetes_persistent_volume_claim_v1.ha_data.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}
