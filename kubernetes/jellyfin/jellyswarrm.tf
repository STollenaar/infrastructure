resource "kubernetes_deployment" "jellyswarrm" {
  metadata {
    name      = "jellyswarrm"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      app = "jellyswarrm"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jellyswarrm"
      }
    }

    template {
      metadata {
        labels = {
          app = "jellyswarrm"
        }
      }

      spec {
        container {
          image = "ghcr.io/llukas22/jellyswarrm:0.3.0"
          name  = "jellyswarrm"

          port {
            container_port = 3000
          }

          env {
            name  = "JELLYSWARRM_USERNAME"
            value = "admin"
          }

          env {
            name  = "JELLYSWARRM_PASSWORD"
            value = random_password.jellyswarrm_server_password.result
          }

          volume_mount {
            name       = "data"
            mount_path = "/app/data"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyswarrm_data.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jellyswarrm" {
  metadata {
    name      = "jellyswarrm"
    namespace = kubernetes_namespace.jellyfin.id
  }

  spec {
    selector = {
      app = "jellyswarrm"
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "jellyswarrm_data" {
  metadata {
    name      = "jellyswarrm-data"
    namespace = kubernetes_namespace.jellyfin.id
  }

  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_manifest" "jellyswarrm_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "jellyswarrm"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "jellyswarrm.home.spicedelver.me"
      tls = {
        secret = "jellyswarrm-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "jellyswarrm"
        service = kubernetes_service.jellyswarrm.metadata.0.name
        port    = 3000
      }]
      routes = [{
        path = "/"
        action = {
          pass = "jellyswarrm"
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "jellyswarrm_public_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "jellyswarrm-public"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "jellyswarrm.spicedelver.me"
      externalDNS = {
        enable = true
      }
      tls = {
        secret = "jellyswarrm-public-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "jellyswarrm"
        service = kubernetes_service.jellyswarrm.metadata.0.name
        port    = 3000
      }]
      routes = [{
        path = "/"
        action = {
          pass = "jellyswarrm"
        }
      }]
    }
  }
}

resource "random_password" "jellyswarrm_server_password" {
  length = 10
}

resource "aws_ssm_parameter" "jellyswarrm_server_password" {
  name  = "/jellyswarrm/server_password"
  type  = "SecureString"
  value = random_password.jellyswarrm_server_password.result
}
