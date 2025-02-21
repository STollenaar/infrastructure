resource "kubernetes_namespace_v1" "uptime_kuma" {
  metadata {
    name = "uptime-kuma"
    labels = {
      app = "uptime-kuma"
    }
  }
}

resource "kubernetes_deployment_v1" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace_v1.uptime_kuma.metadata.0.name
    labels = {
      app = "uptime-kuma"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "uptime-kuma"
      }
    }
    template {
      metadata {
        labels = {
          app = "uptime-kuma"
        }
      }
      spec {
        container {
          name  = "uptime-kuma"
          image = "louislam/uptime-kuma:1"
          port {
            container_port = 3001
          }
          volume_mount {
            mount_path = "/app/data"
            name       = "uptime-kuma-storage"
          }
        }
        volume {
          name = "uptime-kuma-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.uptime_kuma_pvc.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace_v1.uptime_kuma.metadata.0.name
  }
  spec {
    selector = {
      app = "uptime-kuma"
    }
    port {
      protocol    = "TCP"
      port        = 3001
      target_port = 3001
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "uptime_kuma_pvc" {
  metadata {
    name      = "uptime-kuma-pvc"
    namespace = kubernetes_namespace_v1.uptime_kuma.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_ingress_v1" "uptime_kuma_ingress" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace_v1.uptime_kuma.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "status.home.spicedelver.me"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.uptime_kuma.metadata.0.name
              port {
                number = 3001
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "status.home.spicedelver.me",
      ]
      secret_name = "uptime-kuma-tls"
    }
  }
}

resource "kubernetes_ingress_v1" "uptime_kuma_ingress_public" {
  metadata {
    name      = "uptime-kuma-public"
    namespace = kubernetes_namespace_v1.uptime_kuma.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "status.spicedelver.me"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.uptime_kuma.metadata.0.name
              port {
                number = 3001
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "status.spicedelver.me"
      ]
      secret_name = "uptime-kuma-tls-public"
    }
  }
}
