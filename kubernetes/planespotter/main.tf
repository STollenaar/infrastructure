locals {
  location              = split(";", data.aws_ssm_parameter.planes_location.value)
  planespotter_timezone = "America/StJohns"

  # Receiver location, used by readsb for range stats and by tar1090 to draw the
  # site marker. These are local-only: nothing is fed to any aggregator.
  # TODO: replace with the real antenna position.
  planespotter_lat   = local.location[0]
  planespotter_lon   = local.location[1]
  planespotter_alt_m = local.location[2]

  # This setup shares received aircraft with third parties, by two separate
  # routes:
  #
  #   - ULTRAFEEDER_CONFIG in ultrafeeder.tf: adsb + mlat uplinks to ten
  #     aggregators (adsb.fi, adsb.lol, airplanes.live, planespotters.net,
  #     theairtraffic, AVDelphi, hpradar, flyitalyadsb, adsbexchange, adsb.win).
  #   - feeders.tf: fr24 and piaware, which feed Flightradar24 and FlightAware
  #     off ultrafeeder's Beast output rather than through ULTRAFEEDER_CONFIG.
  #
  # The two are independent - emptying the feed list does not stop fr24/piaware,
  # and deleting those Deployments does not stop the uplinks.

  planespotter_sdr_gain = "auto"
  planespotter_sdr_ppm  = "0"
}

resource "kubernetes_namespace_v1" "planespotter" {
  metadata {
    name = "planespotter"
    labels = {
      app = "planespotter"
    }
  }
}