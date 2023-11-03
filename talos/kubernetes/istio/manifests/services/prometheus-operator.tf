resource "kubernetes_manifest" "allow_prometheus_operator_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "prometheus-operator"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local",
      ]
      ports = [
        {
          number   = 8080
          name     = "node"
          protocol = "HTTP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "promtheus_operator_kube_p_prometheus_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "prometheus-operator-kube-p-prometheus"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "*prometheus-operator-kube-p-prometheus.${var.monitoring_namespace}.svc.cluster.local",
        "*prometheus-operator-kube-p-prometheus.${var.monitoring_namespace}.svc",
        "*prometheus-operator-kube-p-prometheus.${var.monitoring_namespace}",
        "*prometheus-operator-kube-p-prometheus",
      ]
      tcp = [
        {
          match = [
            {
              port = 9090
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-prometheus.${var.monitoring_namespace}.svc.cluster.local"
                port = {
                  number = 9090
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "promtheus_operator_kube_p_prometheus_destination_rule" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "DestinationRule"
    metadata = {
      name      = "prometheus-operator-kube-p-prometheus"
      namespace = var.monitoring_namespace
    }
    spec = {
      host = "prometheus-operator-kube-p-prometheus.${var.monitoring_namespace}.svc.cluster.local"
      trafficPolicy = {
        tls = {
          mode = "DISABLE"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "promtheus_operator_kube_p_operator_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "prometheus-operator-kube-p-operator"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local",
        "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}",
        "*prometheus-operator-kube-p-operator",
      ]
      http = [
        {
          match = [
            {
              port = 8080
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
                host = "prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tls = [
        {
          match = [
            {
              port = 443
              sniHosts = [
                "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local",
                "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}",
                "*prometheus-operator-kube-p-operator",
              ]
            },
            {
              port = 80
              sniHosts = [
                "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local",
                "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}",
                "*prometheus-operator-kube-p-operator",
              ]
            },
            {
              port = 8080
              sniHosts = [
                "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local",
                "*prometheus-operator-kube-p-operator.${var.monitoring_namespace}",
                "*prometheus-operator-kube-p-operator",
              ]
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tcp = [
        {
          match = [
            {
              port = 8080
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
                host = "prometheus-operator-kube-p-operator.${var.monitoring_namespace}.svc.cluster.local"
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
