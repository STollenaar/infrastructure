
resource "kubernetes_deployment" "byparr" {
  metadata {
    name      = "byparr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "byparr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "byparr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "byparr"
        }
      }

      spec {
        security_context {
          fs_group = 1000
        }
        container {
          image = "ghcr.io/thephaseless/byparr:7e2d97e1c3026a4754cd7ec5ce44d34efc885b43-amd64"
          name  = "byparr"
          port {
            container_port = 8191
            name           = "byparr"
          }
          resources {
            limits = {
              "memory" = "2Gi"
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_service" "byparr" {
  metadata {
    name      = "byparr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "byparr"
    }
    port {
      name        = "byparr"
      port        = 8191
      target_port = "byparr"
    }
  }
  depends_on = [
    kubernetes_deployment.byparr
  ]
}
