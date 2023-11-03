resource "kubernetes_deployment" "jaeger" {
  metadata {
    name      = "jaeger"
    namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
    labels = {
      app = "jaeger"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "jaeger"
      }
    }
    template {
      metadata {
        labels = {
          app = "jaeger"
        }
        annotations = {
          "sidecar.istio.io/inject" = "false"
          "prometheus.io/scrape"    = "true"
          "prometheus.io/port"      = "14269"
        }
      }
      spec {
        container {
          name  = "jaeger"
          image = "docker.io/jaegertracing/all-in-one:1.50"
          env {
            name  = "BADER_EPHEMERAL"
            value = "false"
          }
          env {
            name  = "SPAN_STORAGE_TYPE"
            value = "badger"
          }
          env {
            name  = "BADGER_DIRECTORY_VALUE"
            value = "/badger/data"
          }
          env {
            name  = "BADGER_DIRECTORY_KEY"
            value = "/badger/key"
          }
          env {
            name  = "COLLECTOR_ZIPKIN_HOST_PORT"
            value = ":9411"
          }
          env {
            name  = "MEMORY_MAX_TRACES"
            value = "50000"
          }
          env {
            name  = "QUERY_BASE_PATH"
            value = "/jaeger"
          }
          liveness_probe {
            http_get {
              path = "/"
              port = "14269"
            }
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "14269"
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/badger"
          }
          resources {
            requests = {
              cpu = "10m"
            }
          }
        }
        volume {
          name = "data"
          empty_dir {}
        }
      }
    }
  }
}
resource "kubernetes_service_v1" "tracing" {
  metadata {
    name      = "tracing"
    namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
    labels = {
      app = "jaeger"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "http-query"
      port        = "80"
      protocol    = "TCP"
      target_port = 16686
    }
    port {
      name        = "grpc-query"
      port        = 16685
      protocol    = "TCP"
      target_port = 16685
    }
    selector = {
      "app" = "jaeger"
    }
  }
}

resource "kubernetes_service_v1" "zipkin" {
  metadata {
    name      = "zipkin"
    namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
    labels = {
      name = "zipkin"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "jaeger"
    }
    port {
      port        = 9411
      target_port = 9411
      name        = "http-query"
    }
  }
}

resource "kubernetes_service_v1" "jeager_collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
    labels = {
      app = "jaeger"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 14268
      name        = "jaeger-collector-http"
      target_port = 14268
      protocol    = "TCP"
    }
    port {
      port        = 14250
      name        = "jaeger-collector-grpc"
      target_port = 14250
      protocol    = "TCP"
    }
    port {
      port        = 9411
      name        = "http-zipkin"
      target_port = 9411
      protocol    = "TCP"
    }
    selector = {
      app = "jaeger"
    }
  }
}
