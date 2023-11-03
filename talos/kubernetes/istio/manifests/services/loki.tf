resource "kubernetes_manifest" "allow_loki_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "loki"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "loki.${var.monitoring_namespace}.svc.cluster.local",
      ]
      ports = [
        {
          number   = 3100
          name     = "http-metrics"
          protocol = "HTTP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}
resource "kubernetes_manifest" "allow_loki_headless_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "loki-headless"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "loki-headless.${var.monitoring_namespace}.svc.cluster.local",
      ]
      ports = [
        {
          number   = 3100
          name     = "http-metrics"
          protocol = "HTTP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "loki_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "loki"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "*loki.${var.monitoring_namespace}.svc.cluster.local",
        "*loki.${var.monitoring_namespace}.svc",
        "*loki.${var.monitoring_namespace}",
        "*loki",
      ]
      http = [
        {
          match = [
            {
              port = 3100
            }
          ]
          route = [
            {
              destination = {
                host = "loki.${var.monitoring_namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tls = [
        {
          match = [
            {
              port = 3100
              sniHosts = [
                "*loki.${var.monitoring_namespace}.svc.cluster.local",
                "*loki.${var.monitoring_namespace}.svc",
                "*loki.${var.monitoring_namespace}",
                "*loki",
              ]
            }
          ]
          route = [
            {
              destination = {
                host = "loki.${var.monitoring_namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tcp = [
        {
          match = [
            {
              port = 3100
            }
          ]
          route = [
            {
              destination = {
                host = "loki.${var.monitoring_namespace}.svc.cluster.local"
                port = {
                  number = 3100
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "loki_headless_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "loki-headless"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "*loki-headless.${var.monitoring_namespace}.svc.cluster.local",
        "*loki-headless.${var.monitoring_namespace}.svc",
        "*loki-headless.${var.monitoring_namespace}",
        "*loki-headless",
      ]
      http = [
        {
          match = [
            {
              port = 3100
            }
          ]
          route = [
            {
              destination = {
                host = "loki-headless.${var.monitoring_namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tls = [
        {
          match = [
            {
              port = 3100
              sniHosts = [
                "*loki-headless.${var.monitoring_namespace}.svc.cluster.local",
                "*loki-headless.${var.monitoring_namespace}.svc",
                "*loki-headless.${var.monitoring_namespace}",
                "*loki-headless",
              ]
            }
          ]
          route = [
            {
              destination = {
                host = "loki-headless.${var.monitoring_namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tcp = [
        {
          match = [
            {
              port = 3100
            }
          ]
          route = [
            {
              destination = {
                host = "loki-headless.${var.monitoring_namespace}.svc.cluster.local"
                port = {
                  number = 3100
                }
              }
            }
          ]
        }
      ]
    }
  }
}
