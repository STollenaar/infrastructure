
resource "kubernetes_deployment" "flaresolverr" {
  metadata {
    name      = "flaresolverr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "flaresolverr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "flaresolverr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "flaresolverr"
        }
      }

      spec {
        security_context {
          fs_group = 1000
        }
        container {
          image = "ghcr.io/flaresolverr/flaresolverr:latest"
          name  = "flaresolverr"
          port {
            container_port = 8191
            name           = "flaresolverr"
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_service" "flaresolverr" {
  metadata {
    name      = "flaresolverr"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "flaresolverr"
    }
    port {
      name        = "flaresolverr"
      port        = 8191
      target_port = "flaresolverr"
    }
  }
  depends_on = [
    kubernetes_deployment.flaresolverr
  ]
}
