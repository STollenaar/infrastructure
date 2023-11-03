resource "kubernetes_manifest" "alertmanager_service_entry" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "alertmanager"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
      ]
      ports = [
        {
          number   = 9093
          name     = "http-web"
          protocol = "TCP"
        },
        {
          number   = 8080
          name     = "reloader-web"
          protocol = "TCP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}


resource "kubernetes_manifest" "alertmanager_virtual_service" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "alertmanager"
      namespace = var.monitoring_namespace
    }
    spec = {
      hosts = [
        "alertmanager.${var.base_domain}",
        "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
        "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc",
        "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}",
        "*prometheus-operator-kube-p-alertmanager",
      ]
      http = [
        {
          match = [
            {
              port = 8080
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local"
                # port = {
                #   number = 9093
                # }
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
                "alertmanager.${var.base_domain}",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}",
                "*prometheus-operator-kube-p-alertmanager",
              ]
            },
            {
              port = 9093
              sniHosts = [
                "alertmanager.${var.base_domain}",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}",
                "*prometheus-operator-kube-p-alertmanager",
              ]
            },
            {
              port = 8080
              sniHosts = [
                "alertmanager.${var.base_domain}",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc",
                "*prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}",
                "*prometheus-operator-kube-p-alertmanager",
              ]
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
                # port = {
                #   number = 9093
                # }
              }
            }
          ]
        }
      ]
      tcp = [
        {
          match = [
            {
              port = 9093
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
                port = {
                  number = 9093
                }
              }
            }
          ]
        }
      ]
    }
  }
}
