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
    namespace = kubernetes_namespace_v1.uptime_kuma.id
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
          image = "louislam/uptime-kuma:2.5.0"
          port {
            container_port = 3001
          }
          resources {
            requests = {
              cpu    = "10m"
              memory = "130Mi"
            }
            limits = {
              memory = "260Mi"
            }
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
  lifecycle {
    ignore_changes = [
      spec.0.replicas
    ]
  }
}

resource "kubernetes_service_v1" "uptime_kuma" {
  metadata {
    name      = "uptime-kuma"
    namespace = kubernetes_namespace_v1.uptime_kuma.id
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
    namespace = kubernetes_namespace_v1.uptime_kuma.id
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

resource "kubernetes_manifest" "uptime_kuma_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "uptime-kuma"
      namespace = kubernetes_namespace_v1.uptime_kuma.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "status.home.spicedelver.me"
      tls = {
        secret = "uptime-kuma-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "uptime-kuma"
        service = kubernetes_service_v1.uptime_kuma.metadata.0.name
        port    = 3001
      }]
      routes = [{
        path = "/"
        action = {
          pass = "uptime-kuma"
        }
      }]
    }
  }
}

# Public host, but external-dns does not manage its record: the old Ingress had no
# external-dns hostname annotation, so spec.externalDNS is deliberately unset.
resource "kubernetes_manifest" "uptime_kuma_public_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "uptime-kuma-public"
      namespace = kubernetes_namespace_v1.uptime_kuma.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "status.spicedelver.me"
      tls = {
        secret = "uptime-kuma-tls-public"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "uptime-kuma"
        service = kubernetes_service_v1.uptime_kuma.metadata.0.name
        port    = 3001
      }]
      routes = [{
        path = "/"
        action = {
          pass = "uptime-kuma"
        }
      }]
    }
  }
}
