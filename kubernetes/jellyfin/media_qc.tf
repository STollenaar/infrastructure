# media-qc: checks downloaded movies for missing English and uploader watermarks.
#
# Radarr calls the service's webhook on every import/upgrade (the service registers
# that webhook itself on startup, since Radarr's Connect settings live in its
# database, not in config.xml). Files are queued in the jellyfin Postgres and scanned
# one at a time:
#   - language: ffprobe audio/subtitle tags + subtitle files Bazarr drops next to
#     the movie.
#   - picture:  sampled frames go to the gemma4-26b vision model through LiteLLM
#     (see ../ollama/llama-swap.tf, where that model keeps its vision projector).
# Flagged movies wait on https://media-qc.home.spicedelver.me for a person to press
# Keep or Reject; nothing is blocklisted or deleted automatically.
#
# The script is conf/media-qc.py. There is no image pipeline in this repo, so the
# container installs ffmpeg and psycopg on start, the same way the other jobs here
# run plain python images with a mounted script.

resource "kubernetes_deployment" "media_qc" {
  metadata {
    name      = "media-qc"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      app = "media-qc"
    }
  }

  spec {
    replicas = 1

    # The queue is built for a single worker.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "media-qc"
      }
    }

    template {
      metadata {
        labels = {
          app = "media-qc"
        }
        annotations = {
          "checksum/script" = sha256(file("${path.module}/conf/media-qc.py"))
        }
      }

      spec {
        init_container {
          name    = "create-db"
          image   = "postgres:18.7-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'media_qc'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres media_qc"
          ]
          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }

        container {
          name    = "media-qc"
          image   = "python:3.15-alpine"
          command = ["/bin/sh", "-ec"]
          args = [
            "apk add --no-cache ffmpeg >/dev/null && pip install --no-cache-dir --root-user-action=ignore -q 'psycopg[binary]==3.2.9' && exec python3 -u /opt/media-qc/media-qc.py"
          ]

          port {
            container_port = 8080
          }

          env {
            name  = "TZ"
            value = local.timezone
          }
          env {
            name  = "DATABASE_URL"
            value = "postgresql://postgres:password@postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local:5432/media_qc"
          }
          env {
            name  = "RADARR_URL"
            value = "http://${kubernetes_service.radarr.metadata.0.name}:7878"
          }
          env {
            name = "RADARR_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.decluttarr_secrets.metadata[0].name
                key  = "RADARR_KEY"
              }
            }
          }
          env {
            name  = "LITELLM_URL"
            value = "http://litellm-service.ollama.svc.cluster.local:4000"
          }
          env {
            name  = "VISION_MODEL"
            value = "gemma4-26b"
          }
          # What Radarr calls. Radarr runs in this namespace, so the short name works.
          env {
            name  = "WEBHOOK_URL"
            value = "http://media-qc:8080/hooks/radarr"
          }
          #   env {
          #     name = "WEBHOOK_TOKEN"
          #     value_from {
          #       secret_key_ref {
          #         name = kubernetes_secret_v1.media_qc.metadata[0].name
          #         key  = "WEBHOOK_TOKEN"
          #       }
          #     }
          #   }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.media_qc.metadata.0.name
            }
          }
          # Gives Bazarr time to fetch subtitles before the language check runs.
          env {
            name  = "WEBHOOK_DELAY_MINUTES"
            value = "30"
          }
          env {
            name  = "FRAME_COUNT"
            value = "30"
          }
          # Below this the model's watermark/subtitle/camcorder answer is ignored.
          env {
            name  = "MIN_CONFIDENCE"
            value = "0.6"
          }
          # A non-English film with English subtitles counts as having an English option.
          env {
            name  = "ALLOW_SUBS_FOR_FOREIGN"
            value = "true"
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            period_seconds = 10
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              # ffmpeg decoding a single 4K remux frame.
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = "script"
            mount_path = "/opt/media-qc"
            read_only  = true
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
          # Same mount paths as Radarr, so the paths it reports can be opened as-is.
          volume_mount {
            name       = "movies"
            mount_path = "/movies"
            read_only  = true
          }
          volume_mount {
            name       = "anime"
            mount_path = "/anime"
            read_only  = true
          }
        }

        volume {
          name = "script"
          config_map {
            name = kubernetes_config_map_v1.media_qc_script.metadata[0].name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.media_qc_data.metadata[0].name
          }
        }
        volume {
          name = "movies"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_movies.metadata.0.name
          }
        }
        volume {
          name = "anime"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyfin_anime_movies.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_config_map_v1" "media_qc_script" {
  metadata {
    name      = "media-qc-script"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "media-qc.py" = file("${path.module}/conf/media-qc.py")
  }
}

resource "random_password" "media_qc_webhook_token" {
  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "media_qc" {
  metadata {
    name      = "media-qc"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    WEBHOOK_TOKEN = random_password.media_qc_webhook_token.result
    LITELLM_KEY   = data.aws_ssm_parameter.media_qc_api_key.value
    # Gets one message per batch of newly flagged movies (Discord webhook URL or any
    # endpoint that takes a JSON POST). Test it with POST /api/notify-test.
    NOTIFY_WEBHOOK_URL = data.aws_ssm_parameter.media_qc_notify_webhook_url.value
  }
}

# Frames of flagged movies, shown on the review page. Clean scans keep none.
resource "kubernetes_persistent_volume_claim" "media_qc_data" {
  metadata {
    name      = "media-qc-data"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_service" "media_qc" {
  metadata {
    name      = "media-qc"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "media-qc"
    }
    port {
      port = 8080
    }
  }
}

# One-time scan of the movies already on disk. The endpoint only queues files that
# are not queued yet, so re-running this (e.g. after the Job is deleted) is harmless.
resource "kubernetes_job_v1" "media_qc_backfill" {
  depends_on = [kubernetes_deployment.media_qc]
  metadata {
    name      = "media-qc-backfill"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      app = "media-qc-backfill"
    }
  }
  spec {
    backoff_limit = 4
    template {
      metadata {
        labels = {
          app = "media-qc-backfill"
        }
      }
      spec {
        restart_policy = "OnFailure"
        container {
          name  = "backfill"
          image = "curlimages/curl:8.23.0"
          # The service installs its packages on start, so give it a few minutes.
          args = [
            "-fsS", "--retry", "30", "--retry-delay", "10", "--retry-all-errors",
            "-X", "POST", "http://${kubernetes_service.media_qc.metadata.0.name}:8080/api/backfill"
          ]
        }
      }
    }
  }
  wait_for_completion = false
}

resource "kubernetes_manifest" "media_qc_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "media-qc"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "media-qc.home.spicedelver.me"
      tls = {
        secret = "media-qc-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "media-qc"
        service = kubernetes_service.media_qc.metadata.0.name
        port    = 8080
        # A Reject talks to Radarr; leave room for it.
        "read-timeout" = "120s"
      }]
      routes = [
        # Radarr reaches the webhook inside the cluster; don't expose it.
        {
          path = "/hooks"
          action = {
            return = {
              code = 404
              body = "not found"
            }
          }
        },
        {
          path = "/"
          action = {
            pass = "media-qc"
          }
        }
      ]
    }
  }
}
