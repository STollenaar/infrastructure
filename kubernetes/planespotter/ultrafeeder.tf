resource "kubernetes_deployment_v1" "ultrafeeder" {
  metadata {
    name      = "ultrafeeder"
    namespace = kubernetes_namespace_v1.planespotter.id
    labels = {
      app = "ultrafeeder"
    }
  }

  spec {
    replicas = 1

    # Single RTL-SDR and ReadWriteOnce volumes: the old pod has to release both
    # before a new one can start.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "ultrafeeder"
      }
    }

    template {
      metadata {
        labels = {
          app = "ultrafeeder"
        }
      }

      spec {
        hostname = "ultrafeeder"

        container {
          name  = "ultrafeeder"
          image = "ghcr.io/sdr-enthusiasts/docker-adsb-ultrafeeder:latest-build-956"

          env {
            name  = "LOGLEVEL"
            value = "error"
          }
          env {
            name  = "TZ"
            value = local.planespotter_timezone
          }

          # readsb drives the dongle directly. With a dedicated ADS-B receiver
          # there is no band to share and nothing to time-slice, so the whole
          # arbiter/decoder arrangement is gone.
          env {
            name  = "READSB_DEVICE_TYPE"
            value = "rtlsdr"
          }
          # Selected by EEPROM serial, not index: readsb's find_device_index
          # falls through to an exact serial match, so this cannot pick up the
          # meter dongle no matter what order libusb enumerates them in.
          env {
            name  = "READSB_RTLSDR_DEVICE"
            value = var.rtlsdr_adsb_serial
          }
          env {
            name  = "READSB_GAIN"
            value = local.planespotter_sdr_gain
          }
          env {
            name  = "READSB_RTLSDR_PPM"
            value = local.planespotter_sdr_ppm
          }
          env {
            name  = "READSB_LAT"
            value = local.planespotter_lat
          }
          env {
            name  = "READSB_LON"
            value = local.planespotter_lon
          }
          env {
            name  = "READSB_ALT"
            value = "${local.planespotter_alt_m}m"
          }
          env {
            name  = "READSB_RX_LOCATION_ACCURACY"
            value = "2"
          }
          env {
            name  = "READSB_STATS_RANGE"
            value = "true"
          }

          # tar1090 web UI.
          env {
            name  = "UPDATE_TAR1090"
            value = "true"
          }
          env {
            name  = "TAR1090_PAGETITLE"
            value = "planespotter"
          }
          env {
            name  = "TAR1090_MESSAGERATEINTITLE"
            value = "true"
          }
          env {
            name  = "TAR1090_PLANECOUNTINTITLE"
            value = "true"
          }
          env {
            name  = "TAR1090_ENABLE_AC_DB"
            value = "true"
          }
          env {
            name  = "TAR1090_FLIGHTAWARELINKS"
            value = "true"
          }
          env {
            name  = "TAR1090_SITESHOW"
            value = "true"
          }
          env {
            name  = "TAR1090_RANGE_OUTLINE_COLORED_BY_ALTITUDE"
            value = "true"
          }
          env {
            name  = "TAR1090_RANGE_OUTLINE_WIDTH"
            value = "2.0"
          }
          env {
            name  = "TAR1090_RANGERINGSDISTANCES"
            value = "50,100,150,200"
          }
          env {
            name  = "TAR1090_RANGERINGSCOLORS"
            value = "'#1A237E','#0D47A1','#42A5F5','#64B5F6'"
          }
          # Route lookups against the adsb.lol API are fine; feeding contacts to
          # the aggregators is what we opt out of (see ULTRAFEEDER_CONFIG above).
          env {
            name  = "TAR1090_USEROUTEAPI"
            value = "true"
          }
          env {
            name  = "GRAPHS1090_DARKMODE"
            value = "true"
          }

          port {
            container_port = 80
            name           = "http"
          }


          # Holds the ADS-B dongle for the life of the pod, which is fine now
          # that it has one of its own - the meter has METER001 and this has
          # ADSB0001, so neither can starve the other. Requesting the device
          # also pins this pod to the node the dongle is plugged into.
          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu                    = "2"
              memory                 = "1Gi"
              "devic.es/rtlsdr-adsb" = 1
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 15
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            failure_threshold     = 5
          }

          volume_mount {
            name       = "globe-history"
            mount_path = "/var/globe_history"
          }
          volume_mount {
            name       = "graphs1090"
            mount_path = "/var/lib/collectd"
          }
          volume_mount {
            name       = "receiver-json"
            mount_path = "/run/readsb"
          }
        }

        volume {
          name = "globe-history"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.ultrafeeder_globe_history.metadata.0.name
          }
        }

        volume {
          name = "graphs1090"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.ultrafeeder_graphs1090.metadata.0.name
          }
        }

        # tmpfs in the reference compose; readsb rewrites these JSON blobs every
        # second and they must not hit disk.
        volume {
          name = "receiver-json"
          empty_dir {
            medium     = "Memory"
            size_limit = "128Mi"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec.0.replicas
    ]
  }
}

resource "kubernetes_persistent_volume_claim_v1" "ultrafeeder_globe_history" {
  metadata {
    name      = "ultrafeeder-globe-history"
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

resource "kubernetes_persistent_volume_claim_v1" "ultrafeeder_graphs1090" {
  metadata {
    name      = "ultrafeeder-graphs1090"
    namespace = kubernetes_namespace_v1.planespotter.id
  }
  wait_until_bound = false
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "openebs-hostpath"
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_service_v1" "ultrafeeder" {
  metadata {
    name      = "ultrafeeder"
    namespace = kubernetes_namespace_v1.planespotter.id
  }
  spec {
    selector = {
      app = "ultrafeeder"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}

# Internal host only: external-dns is not enabled, matching the other
# home.spicedelver.me services.
resource "kubernetes_manifest" "ultrafeeder_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "ultrafeeder"
      namespace = kubernetes_namespace_v1.planespotter.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "planespotter.home.spicedelver.me"
      tls = {
        secret = "ultrafeeder-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "ultrafeeder"
        service = kubernetes_service_v1.ultrafeeder.metadata.0.name
        port    = 80
      }]
      routes = [{
        path = "/"
        action = {
          pass = "ultrafeeder"
        }
      }]
    }
  }
}
