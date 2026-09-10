locals {
  planespotter_beast_host = "${kubernetes_service_v1.ultrafeeder.metadata.0.name}.${kubernetes_namespace_v1.planespotter.id}.svc.cluster.local"

  # readsb Beast output, and the MLATHUB Beast input piaware returns results to.
  planespotter_beast_out_port  = 30005
  planespotter_mlathub_in_port = 31004
}

resource "kubernetes_secret_v1" "fr24" {
  metadata {
    name      = "fr24"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    # TODO: replace placeholder.
    FR24KEY = data.aws_ssm_parameter.flight_radar_key.value

    # UAT is 978 MHz and US-only; there is no second receiver for it here, so
    # this stays empty.
    FR24KEY_UAT = ""
  }
}

resource "kubernetes_config_map_v1" "fr24" {
  metadata {
    name      = "fr24"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    TZ = local.planespotter_timezone

    BEASTHOST = local.planespotter_beast_host
    BEASTPORT = tostring(local.planespotter_beast_out_port)
  }
}

resource "kubernetes_deployment_v1" "fr24" {
  metadata {
    name      = "fr24"
    namespace = kubernetes_namespace_v1.planespotter.id
    labels = {
      app = "fr24"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "fr24"
      }
    }

    template {
      metadata {
        labels = {
          app = "fr24"
        }
        annotations = {
          "checksum/config" = sha256(jsonencode(kubernetes_config_map_v1.fr24.data))
        }
      }

      spec {
        container {
          name  = "fr24"
          image = "ghcr.io/sdr-enthusiasts/docker-flightradar24:latest-build-860"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.fr24.metadata.0.name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.fr24.metadata.0.name
            }
          }

          port {
            container_port = 8754
            name           = "http"
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          # tmpfs in the reference compose: the feeder rewrites logs constantly
          # and none of it is worth keeping across restarts.
          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }
        }

        volume {
          name = "varlog"
          empty_dir {
            medium     = "Memory"
            size_limit = "64Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "fr24" {
  metadata {
    name      = "fr24"
    namespace = kubernetes_namespace_v1.planespotter.id
  }
  spec {
    selector = {
      app = "fr24"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8754
      target_port = 8754
    }
  }
}

resource "kubernetes_secret_v1" "piaware" {
  metadata {
    name      = "piaware"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    FEEDER_ID = data.aws_ssm_parameter.flight_aware_feeder_id.value
  }
}

resource "kubernetes_config_map_v1" "piaware" {
  metadata {
    name      = "piaware"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    TZ = local.planespotter_timezone

    BEASTHOST = local.planespotter_beast_host
    BEASTPORT = tostring(local.planespotter_beast_out_port)

    # piaware runs its own mlat-client and pushes the results back into
    # ultrafeeder's MLATHUB, so MLAT-derived positions appear on tar1090
    # alongside the aircraft received directly.
    MLAT_RESULTS_BEASTHOST = local.planespotter_beast_host
    MLAT_RESULTS_BEASTPORT = tostring(local.planespotter_mlathub_in_port)
  }
}

resource "kubernetes_deployment_v1" "piaware" {
  metadata {
    name      = "piaware"
    namespace = kubernetes_namespace_v1.planespotter.id
    labels = {
      app = "piaware"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "piaware"
      }
    }

    template {
      metadata {
        labels = {
          app = "piaware"
        }
        annotations = {
          "checksum/config" = sha256(jsonencode(kubernetes_config_map_v1.piaware.data))
        }
      }

      spec {
        container {
          name  = "piaware"
          image = "ghcr.io/sdr-enthusiasts/docker-piaware:latest-build-667"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.piaware.metadata.0.name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.piaware.metadata.0.name
            }
          }

          port {
            container_port = 8080
            name           = "http"
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "1"
              memory = "512Mi"
            }
          }

          # The compose mounts /run as tmpfs with exec, because piaware runs
          # helper scripts out of it. emptyDir is not mounted noexec, so the
          # memory medium is the equivalent.
          volume_mount {
            name       = "run"
            mount_path = "/run"
          }
          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }
        }

        volume {
          name = "run"
          empty_dir {
            medium     = "Memory"
            size_limit = "64Mi"
          }
        }

        volume {
          name = "varlog"
          empty_dir {
            medium     = "Memory"
            size_limit = "64Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "piaware" {
  metadata {
    name      = "piaware"
    namespace = kubernetes_namespace_v1.planespotter.id
  }
  spec {
    selector = {
      app = "piaware"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }
}
