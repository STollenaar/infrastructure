locals {
  # Aggregator uplinks, taken from the reference compose.
  #
  # MLAT is not a standalone setting: mlat-client only works against a server
  # you are already feeding ADS-B to, because the server needs your Beast feed
  # to correlate timing against other receivers. So each mlat entry travels with
  # its adsb partner, and enabling "the mlat items" necessarily enables the
  # feeds beneath them. Drop a pair to stop feeding that aggregator; drop the
  # whole list to go back to receiving locally and sharing nothing.
  #
  # AVDelphi runs no MLAT server, which is why it has no mlat line.
  planespotter_feeds = [
    "adsb,feed.adsb.fi,30004,beast_reduce_plus_out",
    "mlat,feed.adsb.fi,31090",

    "adsb,in.adsb.lol,30004,beast_reduce_plus_out",
    "mlat,in.adsb.lol,31090",

    "adsb,feed.airplanes.live,30004,beast_reduce_plus_out",
    "mlat,feed.airplanes.live,31090",

    "adsb,feed.planespotters.net,30004,beast_reduce_plus_out",
    "mlat,mlat.planespotters.net,31090",

    "adsb,feed.theairtraffic.com,30004,beast_reduce_plus_out",
    "mlat,feed.theairtraffic.com,31090",

    "adsb,data.avdelphi.com,24999,beast_reduce_plus_out",

    "adsb,skyfeed.hpradar.com,30004,beast_reduce_plus_out",
    "mlat,skyfeed.hpradar.com,31090",

    "adsb,dati.flyitalyadsb.com,4905,beast_reduce_plus_out",
    "mlat,dati.flyitalyadsb.com,30100",

    "adsb,feed1.adsbexchange.com,30004,beast_reduce_plus_out",
    "mlat,feed.adsbexchange.com,31090",

    # adsb.win issues its own uuid rather than accepting the global one.
    "adsb,feed.adsb.win,30004,beast_reduce_plus_out,uuid=${local.planespotter_adsbwin_uuid}",
    "mlat,mlat.adsb.win,31090,39013,uuid=${local.planespotter_adsbwin_uuid}",
  ]

  # Station identity sent with the feeds. The UUID is what ties these uplinks to
  # your account/stats pages at each aggregator, so it is a stable identifier
  # worth treating like the other credentials here: replace these the way
  # piaware's FEEDER_ID is done, via an SSM parameter in data.tf, rather than by
  # committing the real values.
  # TODO: replace placeholders. Generate the main one with `uuidgen`; adsb.win
  # issues theirs at https://adsb.win.
  planespotter_uuid         = "REPLACE_ME"
  planespotter_adsbwin_uuid = "REPLACE_ME"

  planespotter_mlat_user = "planespotter"
}

resource "kubernetes_config_map_v1" "ultrafeeder" {
  metadata {
    name      = "ultrafeeder"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    LOGLEVEL = "error"
    TZ       = local.planespotter_timezone

    # readsb drives the dongle directly. With a dedicated ADS-B receiver there
    # is no band to share and nothing to time-slice.
    READSB_DEVICE_TYPE = "rtlsdr"

    # Selected by EEPROM serial, not index: readsb's find_device_index falls
    # through to an exact serial match, so this cannot pick up the meter dongle
    # no matter what order libusb enumerates them in.
    READSB_RTLSDR_DEVICE = var.rtlsdr_adsb_serial

    READSB_GAIN                 = local.planespotter_sdr_gain
    READSB_RTLSDR_PPM           = local.planespotter_sdr_ppm
    READSB_LAT                  = local.planespotter_lat
    READSB_LON                  = local.planespotter_lon
    READSB_ALT                  = "${local.planespotter_alt_m}m"
    READSB_RX_LOCATION_ACCURACY = "2"
    READSB_STATS_RANGE          = "true"

    # tar1090 web UI.
    UPDATE_TAR1090                            = "true"
    TAR1090_PAGETITLE                         = "planespotter"
    TAR1090_MESSAGERATEINTITLE                = "true"
    TAR1090_PLANECOUNTINTITLE                 = "true"
    TAR1090_ENABLE_AC_DB                      = "true"
    TAR1090_FLIGHTAWARELINKS                  = "true"
    TAR1090_SITESHOW                          = "true"
    TAR1090_RANGE_OUTLINE_COLORED_BY_ALTITUDE = "true"
    TAR1090_RANGE_OUTLINE_WIDTH               = "2.0"
    TAR1090_RANGERINGSDISTANCES               = "50,100,150,200"
    TAR1090_RANGERINGSCOLORS                  = "'#1A237E','#0D47A1','#42A5F5','#64B5F6'"

    # Route lookups against the adsb.lol API are fine; feeding contacts to the
    # aggregators is what we opt out of (see ULTRAFEEDER_CONFIG in main.tf).
    TAR1090_USEROUTEAPI = "true"

    # Username shown against your MLAT contributions on the aggregators' maps.
    MLAT_USER = local.planespotter_mlat_user

    # Feed MLAT-derived positions back into readsb's SBS output so they show on
    # tar1090 next to directly received aircraft. Ultrafeeder logs a warning
    # when this is set - it means "do not pipe this container's SBS output to an
    # aggregator", since those positions are computed rather than received. We
    # do not, so the warning is expected and harmless.
    READSB_FORWARD_MLAT_SBS = "true"

    GRAPHS1090_DARKMODE = "true"

    # There is no thermal sensor to read: /sys/class/thermal is empty on this
    # node and there is no hwmon, because Proxmox does not expose host
    # temperatures to guests. The panel can never plot anything, so hide it.
    # Note this only hides the chart - collectd still loads its table plugin
    # and will still log that the thermal zone is missing.
    GRAPHS1090_DISABLE_CHART_TEMP = "true"
  }
}

resource "kubernetes_secret_v1" "ultrafeeder_feeds" {
  metadata {
    name      = "ultrafeeder-feeds"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    ULTRAFEEDER_CONFIG = join(";", local.planespotter_feeds)
    UUID               = local.planespotter_uuid
  }
}

resource "kubernetes_config_map_v1" "ident" {
  metadata {
    name      = "ident"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    IDENT_STATION_NAME = "planespotter"

    # HeyWhatsThat panorama id, used to draw the theoretical horizon. Generate
    # one at https://heywhatsthat.com for the receiver location and paste the id
    # here; until then Ident just omits the overlay.
    # TODO: replace placeholder.
    IDENT_HEYWHATSTHAT_PANORAMA_ID = "REPLACE_ME"
    IDENT_HEYWHATSTHAT_ALTS        = "3000,12000"
  }
}

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
        annotations = {
          "checksum/config" = sha256(jsonencode(kubernetes_config_map_v1.ultrafeeder.data))
        }
      }

      spec {
        hostname = "ultrafeeder"

        container {
          name  = "ultrafeeder"
          image = "ghcr.io/sdr-enthusiasts/docker-adsb-ultrafeeder:latest-build-956"

          # Every setting lives in the ConfigMap; a change there rolls the pod
          # via the checksum annotation above, since env_from is only read at
          # container start.
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.ultrafeeder.metadata.0.name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.ultrafeeder_feeds.metadata.0.name
            }
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
          volume_mount {
            name       = "mtab"
            mount_path = "/etc/mtab"
            sub_path   = "mtab"
            read_only  = true
          }
        }

        # Ident reads readsb's aircraft.json straight off the filesystem - it
        # has no HTTP source option and defaults to /run/readsb - so it has to
        # share ultrafeeder's tmpfs. That makes it a sidecar rather than its own
        # Deployment, which is also what the reference compose does with a
        # shared volume. Read-only: it is a viewer, not a feeder.
        container {
          name  = "ident"
          image = "ghcr.io/ident-1090/ident:v0.5.1"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.ident.metadata.0.name
            }
          }

          port {
            container_port = 8080
            name           = "ident"
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

          volume_mount {
            name       = "receiver-json"
            mount_path = "/run/readsb"
            read_only  = true
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

        volume {
          name = "mtab"
          config_map {
            name = kubernetes_config_map_v1.ultrafeeder_mtab.metadata.0.name
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

# collectd's df plugin (graphs1090's disk-usage chart) calls setmntent on
# /etc/mtab, and the ultrafeeder image ships no such file - so it fails every
# cycle and backs off. Nothing to do with Talos; it is a gap in the image.
#
# df is loaded with no <Plugin df> block, so it simply charts whatever mtab
# lists, and it statvfs's each mount point directly - the device names here are
# cosmetic, the usage figures come from the live filesystem. Listing the paths
# we actually care about is enough to make the chart real.
resource "kubernetes_config_map_v1" "ultrafeeder_mtab" {
  metadata {
    name      = "ultrafeeder-mtab"
    namespace = kubernetes_namespace_v1.planespotter.id
  }

  data = {
    "mtab" = <<-EOT
      overlay / overlay rw 0 0
      /dev/globe_history /var/globe_history xfs rw 0 0
      /dev/collectd /var/lib/collectd xfs rw 0 0
    EOT
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
    # readsb Beast output (--net-bo-port), which fr24 and piaware consume.
    port {
      name        = "beast-out"
      protocol    = "TCP"
      port        = 30005
      target_port = 30005
    }
    # MLATHUB Beast input: piaware pushes its MLAT results back in here so they
    # show up on tar1090 alongside the directly received aircraft.
    port {
      name        = "mlathub-in"
      protocol    = "TCP"
      port        = 31004
      target_port = 31004
    }
    port {
      name        = "ident"
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
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
