# heating-agent: watches the thermostats' electricity use in Home Assistant, reads the
# weather forecast, and proposes heating changes. It never changes a thermostat on
# its own: each proposal is sent to the phone as an actionable notification and is
# applied only when Apply is pressed. Cold-snap forecasts trigger an extra scan.
#
# LiteLLM registers it as an A2A agent (`agents:` in conf/litellm/config.yaml), so it
# can be reached through llm.home.spicedelver.me at /a2a/heating-agent.
#
# The script is conf/heating-agent/heating-agent.py. Like media-qc, it runs on a plain
# python image and installs its one dependency on start.
#
# Secrets, created by hand before applying:
#   /homeassistant/heating_agent_token  HA long-lived access token (HA profile ->
#                                       Security -> Long-lived access tokens)
#   /ollama/heating_agent_api_key       LiteLLM virtual key with access to MODEL

locals {
  heating_agent_port = 8080

  # Rated wattage of the baseboard heaters behind each thermostat. The thermostats
  # only report heating demand (% of time on), so these turn demand into kWh. They
  # are placeholders: read the real values off the heater labels. The report's
  # median_kwh_per_hour_without_heating vs the meter shows if they are far off.
  heating_agent_heater_watts = {
    "climate.stelpro_maestrostat"   = 1500 # Living Room
    "climate.stelpro_maestrostat_2" = 1500 # Kitchen
    "climate.stelpro_st218"         = 1000 # Bedroom
    "climate.stelpro_st218_2"       = 1000 # Office
  }
}

resource "kubernetes_deployment" "heating_agent" {
  metadata {
    name      = "heating-agent"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "heating-agent"
    }
  }

  spec {
    replicas = 1

    # Pending proposals and the decision log live in one state file.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "heating-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "heating-agent"
        }
        annotations = {
          "checksum/script" = sha256(file("${path.module}/conf/heating-agent/heating-agent.py"))
        }
      }

      spec {
        container {
          name    = "heating-agent"
          image   = "python:3.15-alpine"
          command = ["/bin/sh", "-ec"]
          # tzdata: alpine has no zoneinfo database.
          args = [
            "pip install --no-cache-dir --root-user-action=ignore -q 'websockets==15.0.1' 'tzdata==2025.2' && exec python3 -u /opt/heating-agent/heating-agent.py"
          ]

          port {
            container_port = local.heating_agent_port
          }

          env {
            name  = "TZ"
            value = "America/St_Johns"
          }
          env {
            name  = "HA_URL"
            value = "http://homeassistant.homeassistant.svc.cluster.local:8123"
          }
          env {
            name  = "LITELLM_URL"
            value = "http://${kubernetes_service.litellm.metadata.0.name}.${kubernetes_namespace.ollama.id}.svc.cluster.local:4000"
          }
          # Structured output is constrained to a JSON schema; gemma4 is the model
          # set up for that (see conf/litellm/config.yaml).
          env {
            name  = "MODEL"
            value = "gemma4-26b"
          }
          # What goes in the agent card, i.e. where LiteLLM sends A2A requests.
          env {
            name  = "AGENT_URL"
            value = "http://heating-agent.${kubernetes_namespace.ollama.id}.svc.cluster.local:${local.heating_agent_port}/"
          }
          env {
            name  = "CLIMATE_ENTITIES"
            value = join(",", keys(local.heating_agent_heater_watts))
          }
          env {
            name  = "HEATER_WATTS"
            value = jsonencode(local.heating_agent_heater_watts)
          }
          # The meter and its $/kWh are read from Home Assistant's Energy settings
          # (grid source) on every scan. METER_ENTITY / ENERGY_PRICE env vars would
          # override them; leave them unset to follow what is configured there.
          env {
            name  = "WEATHER_ENTITY"
            value = "weather.forecast_home"
          }
          # Companion app phones of person.stephen. Either one can approve.
          env {
            name  = "NOTIFY_SERVICES"
            value = "mobile_app_vocmobile"
          }
          env {
            name  = "SCAN_INTERVAL_HOURS"
            value = "6"
          }
          # No routine notifications overnight. Cold-snap scans still go out.
          env {
            name  = "QUIET_HOURS"
            value = "22-7"
          }
          env {
            name  = "PROPOSAL_TTL_MINUTES"
            value = "120"
          }
          env {
            name  = "MIN_SETPOINT"
            value = "15"
          }
          env {
            name  = "MAX_SETPOINT"
            value = "23"
          }
          # A forecast low at or below this within COLD_LOOKAHEAD_HOURS is a cold snap:
          # heat may not be turned off or set below COLD_MIN_SETPOINT.
          env {
            name  = "COLD_THRESHOLD_C"
            value = "-12"
          }
          env {
            name  = "COLD_LOOKAHEAD_HOURS"
            value = "36"
          }
          env {
            name  = "COLD_MIN_SETPOINT"
            value = "17"
          }
          env {
            name  = "STATE_FILE"
            value = "/data/state.json"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.heating_agent.metadata.0.name
            }
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = local.heating_agent_port
            }
            period_seconds = 10
          }

          resources {
            requests = {
              cpu    = "20m"
              memory = "64Mi"
            }
            limits = {
              memory = "256Mi"
            }
          }

          volume_mount {
            name       = "script"
            mount_path = "/opt/heating-agent"
            read_only  = true
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }

        volume {
          name = "script"
          config_map {
            name = kubernetes_config_map_v1.heating_agent_script.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.heating_agent_data.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map_v1" "heating_agent_script" {
  metadata {
    name      = "heating-agent-script"
    namespace = kubernetes_namespace.ollama.id
  }
  data = {
    "heating-agent.py" = file("${path.module}/conf/heating-agent/heating-agent.py")
  }
}

resource "kubernetes_secret_v1" "heating_agent" {
  metadata {
    name      = "heating-agent"
    namespace = kubernetes_namespace.ollama.id
  }
  data = {
    HA_TOKEN    = data.aws_ssm_parameter.heating_agent_ha_token.value
    LITELLM_KEY = data.aws_ssm_parameter.heating_agent_api_key.value
  }
}

# Pending proposals and past decisions, so a restart does not lose what was skipped.
resource "kubernetes_persistent_volume_claim" "heating_agent_data" {
  metadata {
    name      = "heating-agent-data"
    namespace = kubernetes_namespace.ollama.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "100Mi"
      }
    }
  }
}

resource "kubernetes_service" "heating_agent" {
  metadata {
    name      = "heating-agent"
    namespace = kubernetes_namespace.ollama.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "heating-agent"
    }
    port {
      port        = local.heating_agent_port
      target_port = local.heating_agent_port
    }
  }
}
