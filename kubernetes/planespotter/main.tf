locals {
  planespotter_timezone = "America/StJohns"

  # Receiver location, used by readsb for range stats and by tar1090 to draw the
  # site marker. These are local-only: nothing is fed to any aggregator.
  # TODO: replace with the real antenna position.
  planespotter_lat   = "47.59104"
  planespotter_lon   = "-52.70167"
  planespotter_alt_m = "58"

  # ULTRAFEEDER_CONFIG is deliberately left unset. Every entry in that variable is
  # an adsb/mlat uplink to a third-party aggregator (adsb.fi, adsb.lol,
  # airplanes.live, planespotters.net, adsbexchange, ...). Leaving it empty runs
  # readsb + tar1090 purely locally and shares nothing. Same reason there is no
  # UUID / MLAT_USER, and no fr24 or piaware sidecar from the reference compose.

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