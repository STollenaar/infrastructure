resource "kubernetes_manifest" "allow_grafana_dashboard_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "grafana-dashboard-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "grafana.com",

      ]
      ports = [
        {
          number   = 443
          name     = "https"
          protocol = "TLS"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "grafana_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "grafana"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "grafana.${var.base_domain}",
        "*prometheus-operator-grafana.${var.monitoring_namespace}.svc.cluster.local",
        "*prometheus-operator-grafana.${var.monitoring_namespace}.svc",
        "*prometheus-operator-grafana.${var.monitoring_namespace}",
        "*prometheus-operator-grafana",
      ]
      http = [
        {
          match = [
            {
              port = 3000
            },
            {
              port = 80
            },
            {
              port = 443
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-grafana.${var.monitoring_namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
    }
  }
}
