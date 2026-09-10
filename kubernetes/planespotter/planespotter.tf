resource "kubernetes_config_map_v1" "planespotter" {
  metadata {
    name      = "planespotter"
    namespace = kubernetes_namespace_v1.planespotter.id
  }
  data = {
    # Base URL of the ultrafeeder tar1090 instance; planespotter appends
    # /data/aircraft.json to it. Same namespace, so this resolves in-cluster.
    PLANESPOTTER_TAR1090_URL         = "http://${kubernetes_service_v1.ultrafeeder.metadata.0.name}.${kubernetes_namespace_v1.planespotter.id}.svc.cluster.local"
    PLANESPOTTER_DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1527411298105692404/JlSTa0ePmpdimr1yB6GIgFS6x1qVevQ87eWaxsFiANgSoYSEKir59LWW1CDXB-DTdOKD"

    # Optional values with defaults
    PLANESPOTTER_HTTP_ADDR              = ":8080"
    PLANESPOTTER_MONITOR_INTERVAL       = "15s"
    PLANESPOTTER_MAX_ALTITUDE           = "10000"
    PLANESPOTTER_CALLSIGN_WAIT_RECEIVES = "4"
    PLANESPOTTER_DATA_PATH              = "."
    PLANESPOTTER_CCAR_ENABLED           = "true"
    PLANESPOTTER_LOG_LEVEL              = "DEBUG"

    PLANESPOTTER_DISCORD_WEBHOOK_THREAD_ID = ""
    PLANESPOTTER_FLIGHT_AWARE_API_KEY      = data.aws_ssm_parameter.flight_aware_key.value
  }
}

resource "kubernetes_deployment_v1" "planespotter" {
  metadata {
    name      = "planespotter"
    namespace = kubernetes_namespace_v1.planespotter.id
  }
  spec {
    selector {
      match_labels = {
        app = "planespotter"
      }
    }

    template {
      metadata {
        labels = {
          app = "planespotter"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_manifest.planespotter_external_secret.manifest.spec.target.name
        }
        container {
          name  = "planespotter"
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/discordbots:planespotter-0.0.2"
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.planespotter.metadata.0.name
            }
          }
          volume_mount {
            name       = "seen"
            mount_path = "/seen"
          }
        }
        volume {
          name = "seen"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.planespotter_seen.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "planespotter_seen" {
  metadata {
    name      = "planespotter-seen"
    namespace = kubernetes_namespace_v1.planespotter.id
  }
  wait_until_bound = false
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "openebs-hostpath"
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_manifest" "planespotter_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace_v1.planespotter.id
    }
    spec = {
      secretStoreRef = {
        name = var.vault_backend.name
        kind = var.vault_backend.kind
      }
      target = {
        name = "regcred"
        template = {
          type          = "kubernetes.io/dockerconfigjson"
          mergePolicy   = "Replace"
          engineVersion = "v2"
        }
      }
      data = [
        {
          secretKey = ".dockerconfigjson"
          remoteRef = {
            key      = "ecr-auth"
            property = ".dockerconfigjson"
          }
        }
      ]
    }
  }
}
