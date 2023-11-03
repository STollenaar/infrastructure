resource "kubernetes_manifest" "allow_prometheus_metrics_query" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-prometheus-metrics-query"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "prometheus-operator-kube-p-prometheus"
        }
      }
      rules = [
        {
          to = [
            {
              operation = {
                methods = [
                  "GET"
                ]
                paths = [
                  "/metrics"
                ]
              }
            }
          ]
        },
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-operator-grafana"
                ]
              }
            },
            {
              source = {
                namespaces = [
                  var.istio_namespace
                ]
                principals = [
                  "cluster.local/ns/${var.istio_namespace}/sa/kiali-service-account"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_prometheus_operator_metrics_query" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-prometheus-operator-metrics-query"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "prometheus-operator"
        }
      }
      rules = [
        {
          to = [
            {
              operation = {
                methods = [
                  "GET"
                ]
                paths = [
                  "/metrics"
                ]
              }
            }
          ]
        },
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-operator-grafana"
                ]
              }
            },
            {
              source = {
                namespaces = [
                  var.istio_namespace
                ]
                principals = [
                  "cluster.local/ns/${var.istio_namespace}/sa/kiali-service-account"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_prometheus_stack_scrape" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-prometheus-stack-scrape"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app" = "kube-prometheus-stack-operator"
        }
      }
      rules = [
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-sa"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_prometheus_state_metrics_scrape" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-prometheus-state-metrics-scrape"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "kube-state-metrics"
        }
      }
      rules = [
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-sa"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_alertmanager" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-alertmanager"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "alertmanager"
        }
      }
      rules = [
        {
          from = [
            # {
            #   source = {
            #    principals = [
            #       "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-sa"
            #     ]
            #   }
            # }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_promtail_metrics" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-promtail-metrics"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "promtail"
        }
      }
      rules = [
        {
          to = [
            {
              operation = {
                hosts = [
                  "loki.${var.monitoring_namespace}.svc.cluster.local",
                  "loki-headless.${var.monitoring_namespace}.svc.cluster.local"
                ]
                ports = [
                  "3100"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_loki_metrics" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-loki-metrics"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          app = "loki"
        }
      }
      rules = [
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/${var.monitoring_namespace}/sa/promtail",
                  "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-operator-grafana"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_grafana" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-grafana"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "grafana"
        }
      }
      rules = [
        {
          from = [
            {
              source = {
                principals = [
                  "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-sa",
                  "cluster.local/ns/${var.monitoring_namespace}/sa/prometheus-operator-sa"
                ]
              }
            },
            {
              source = {
                namespaces = [
                  "default"
                ]
                principals = [
                  "cluster.local/ns/default/sa/nginx-ingress-ingress-nginx"
                ]
              }
            },
            {
              source = {
                namespaces = [
                  var.istio_namespace
                ]
                principals = [
                  "cluster.local/ns/${var.istio_namespace}/sa/kiali-service-account"
                ]
              }
            }
          ]
        },
        {
          to = [
            {
              operation = {
                hosts = [
                  "loki.${var.monitoring_namespace}.svc.cluster.local",
                  "loki-headless.${var.monitoring_namespace}.svc.cluster.local",
                  "prometheus-operator-kube-p-prometheus.${var.monitoring_namespace}.svc.cluster.local"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_prometheus" {

  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-prometheus"
      namespace = var.monitoring_namespace
    }
    spec = {
      action = "ALLOW"
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "prometheus"
        }
      }
      rules = [
        {
          to = [
            {
              operation = {
                hosts = [
                  "alertmanager-operated.${var.monitoring_namespace}.svc.cluster.local",
                  "prometheus-operator-kube-p-alertmanager.${var.monitoring_namespace}.svc.cluster.local",
                  "prometheus-operator-prometheus-node-exporter.${var.monitoring_namespace}.svc.cluster.local"
                ]
              }
            }
          ]
        }
      ]
    }
  }
}
