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
          image = "ghcr.io/llukas22/jellyswarrm:0.2.1"
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

resource "kubernetes_ingress_v1" "jellyswarrm" {
  metadata {
    name      = "jellyswarrm"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "jellyswarrm.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.jellyswarrm.metadata.0.name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "jellyswarrm.home.spicedelver.me"
      ]
      secret_name = "jellyswarrm-tls"
    }
  }
}

resource "kubernetes_ingress_v1" "jellyswarrm_public" {
  metadata {
    name      = "jellyswarrm-public"
    namespace = kubernetes_namespace.jellyfin.id

    annotations = {
      "kubernetes.io/ingress.class"               = "nginx"
      "cert-manager.io/cluster-issuer"            = "letsencrypt-prod"
      "external-dns.alpha.kubernetes.io/hostname" = "jellyswarrm.spicedelver.me"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "jellyswarrm.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.jellyswarrm.metadata.0.name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "jellyswarrm.spicedelver.me"
      ]
      secret_name = "jellyswarrm-public-tls"
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
