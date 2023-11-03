resource "kubernetes_manifest" "allow_prometheus_state_metrics_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "prometheus-state-metrics"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "prometheus-operator-kube-state-metrics.${var.monitoring_namespace}.svc.cluster.local",
      ]
      ports = [
        {
          number   = 8080
          name     = "node"
          protocol = "TCP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}


resource "kubernetes_manifest" "kube_state_metrics_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "prometheus-operator-kube-state-metrics"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "*prometheus-operator-kube-state-metrics.${var.monitoring_namespace}.svc.cluster.local",
        "*prometheus-operator-kube-state-metrics.${var.monitoring_namespace}",
        "*prometheus-operator-kube-state-metrics",
      ]
      tcp = [
        {
          match = [
            {
              port = 8080
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-state-metrics.${var.monitoring_namespace}.svc.cluster.local"
                port = {
                  number = 8080
                }
              }
            }
          ]
        }
      ]
    }
  }
}
