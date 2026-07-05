
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
        image_pull_secrets {
          name = kubernetes_manifest.jellyfin_external_secret.manifest.spec.target.name
        }
        container {
          image = "ghcr.io/thephaseless/byparr:885a24cf160e8baf64b844fc20a91db99fea7826-amd64"
          name  = "byparr"
          port {
            container_port = 8191
            name           = "byparr"
          }
          resources {
            limits = {
              "memory" = "4Gi"
            }
          }
        }
        container {
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/byparr-proxy:0.0.1"
          name  = "byparr-proxy"
          port {
            container_port = 8889
            name           = "byparr-proxy"
          }
          env {
            name  = "UPSTREAM"
            value = "https://1337x.to"
          }
          env {
            name  = "BYPARR"
            value = "http://localhost:8191/v1"
          }
          env {
            name  = "TIMEOUT_MS"
            value = 120000
          }
          env {
            name  = "PORT"
            value = 8889
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
    port {
      name        = "byparr-proxy"
      port        = 8889
      target_port = "byparr-proxy"
    }
  }
  depends_on = [
    kubernetes_deployment.byparr
  ]
}
