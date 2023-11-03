resource "kubernetes_manifest" "allow_node_exporter_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "node-exporter"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "prometheus-operator-prometheus-node-exporter.${var.monitoring_namespace}.svc.cluster.local",
      ]
      ports = [
        {
          number   = 9100
          name     = "node"
          protocol = "TCP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}


resource "kubernetes_manifest" "node_exporter_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "node-exporter"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "*prometheus-operator-prometheus-node-exporter.${var.monitoring_namespace}.svc.cluster.local",
        "*prometheus-operator-prometheus-node-exporter.${var.monitoring_namespace}",
        "*prometheus-operator-prometheus-node-exporter",
      ]
      tcp = [
        {
          match = [
            {
              port = 9100
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-prometheus-node-exporter.${var.monitoring_namespace}.svc.cluster.local"
                port = {
                  number = 9100
                }
              }
            }
          ]
        }
      ]
    }
  }
}
