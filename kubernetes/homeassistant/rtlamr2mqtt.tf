

locals {
  meters = [
    {
      id                  = "27568271"
      protocol            = "scm"
      name                = "electricity_meter"
      unit_of_measurement = "kWh"
      device_class        = "energy"
      state_class         = "total_increasing"
      icon                = "mdi:meter-electric-outline"

      field = "consumption_data"
      format : "#####.##"
    }
  ]

  rtlamr2mqtt_config = {
    general = {
      # Which dongle rtlamr2mqtt opens, by librtlsdr enumeration order.
      #
      # The devic.es/rtlsdr-meter request is what guarantees this pod is handed
      # the meter dongle's node, since that match is on EEPROM serial. This
      # index is the second half: rtlamr2mqtt enumerates with pyusb on
      # vendor:product and does not filter to devices it can actually open, so
      # it sees both dongles and picks positionally.
      #
      # Verified on the running host - libusb orders 9-3 before 9-2, so:
      #   index 0 = ADSB0001 (9-3)
      #   index 1 = METER001 (9-2)  <- this one
      #
      # This is positional and therefore brittle. Re-check it with
      # `rtl_test -d 99` after moving dongles between ports; and note that if
      # the ADS-B dongle is unplugged entirely, only one device enumerates and
      # index 1 goes out of range, which rtlamr2mqtt treats as fatal.
      device_id = 1
    }
    mqtt = {
      ha_autodiscovery       = true
      ha_autodiscovery_topic = "homeassistant"
      base_topic             = "rtlamr"
      host                   = "${kubernetes_service_v1.mosquitto.metadata.0.name}.${kubernetes_namespace_v1.homeassistant.id}.svc.cluster.local"
      port                   = 1883
    }
    meters = [
      for m in local.meters : merge(
        {
          id                  = m.id
          protocol            = m.protocol
          name                = m.name
          unit_of_measurement = m.unit_of_measurement
          format              = m.format
          field               = m.field
        },
        m.icon != null ? { icon = m.icon } : {},
        m.device_class != null ? { device_class = m.device_class } : {},
        m.state_class != null ? { state_class = m.state_class } : {},
      )
    ]
  }

  # Remove nulls so yamlencode doesn’t emit them
  rtlamr2mqtt_config_clean = jsondecode(jsonencode(local.rtlamr2mqtt_config))
}

resource "kubernetes_config_map" "cfg" {
  metadata {
    name      = "rtlamr2mqtt-config"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  data = {
    "rtlamr2mqtt.yaml" = yamlencode(local.rtlamr2mqtt_config_clean)
  }
}

resource "kubernetes_deployment" "rtlamr2mqtt" {
  metadata {
    name      = "rtlamr2mqtt"
    namespace = kubernetes_namespace_v1.homeassistant.id
    labels = {
      app = "rtlamr2mqtt"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "rtlamr2mqtt"
      }
    }

    template {
      metadata {
        labels = {
          app                              = "rtlamr2mqtt"
          "checksum/configmap-rtlamr2mqtt" = kubernetes_config_map.cfg.metadata[0].resource_version
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

        # Needed for direct USB access on most clusters
        container {
          name  = "rtlamr2mqtt"
          image = "allangood/rtlamr2mqtt:2026.5.9"

          # Mount config file
          volume_mount {
            name       = "config"
            mount_path = "/etc/rtlamr2mqtt.yaml"
            sub_path   = "rtlamr2mqtt.yaml"
            read_only  = true
          }

          # The meter dongle (Realtek 0bda:2838 on USB 9-2) is provided by
          # generic-device-plugin as devic.es/rtlsdr-meter, matched on its
          # EEPROM serial so this pod can never be handed the ADS-B dongle.
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu                     = "500m"
              memory                  = "512Mi"
              "devic.es/rtlsdr-meter" = 1
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.cfg.metadata[0].name
          }
        }
      }
    }
  }
}

