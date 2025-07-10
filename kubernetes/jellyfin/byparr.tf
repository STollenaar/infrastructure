
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
          image = "ghcr.io/thephaseless/byparr:latest"
          name  = "byparr"
          port {
            container_port = 8191
            name           = "byparr"
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
