resource "kubernetes_manifest" "force_mutual_tls" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "default"
      namespace = var.istio_namespace
    }
    spec = {
      mtls = {
        mode = "STRICT"
      }
    }
  }
}

resource "kubernetes_manifest" "allow_loki_tls" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "allow-loki"
      namespace = var.monitoring_namespace
    }
    spec = {
      selector = {
        matchLabels = {
          "security.istio.io/tlsMode" = "istio"
        }
      }
      mtls = {
        mode = "UNSET"
      }
      portLevelMtls = {
        3100 = {
          mode = "PERMISSIVE"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "allow_monitoring_tls" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "allow-monitoring"
      namespace = var.monitoring_namespace
    }
    spec = {
      mtls = {
        mode = "PERMISSIVE"
      }
    }
  }
}
