resource "kubernetes_manifest" "disallow_all" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-nothing"
      namespace = var.istio_namespace
    }
    spec = {}
  }
}

resource "kubernetes_manifest" "allow_kiali" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-kiali"
      namespace = var.istio_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "kiali"
        }
      }
      rules = [
        {
          to = [
            {
              operation = {
                hosts = [
                  "prometheus-operator-grafana.${var.monitoring_namespace}.svc.cluster.local",
                  "prometheus-operator-kube-p-prometheus.${var.monitoring_namespace}.svc.cluster.local",
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_nginx" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-nginx"
      namespace = "default"
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "nginx-ingress"
        }
      }
      rules = [
        {
          to = []
        }
      ]
    }
  }
}
