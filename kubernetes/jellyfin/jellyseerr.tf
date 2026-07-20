resource "kubernetes_deployment" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "jellyseerr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "jellyseerr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "jellyseerr"
        }
      }

      spec {
        container {
          image = "ghcr.io/seerr-team/seerr:v3.3.0"
          name  = "jellyseerr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.jellyseerr.metadata.0.name
            }
          }
          port {
            container_port = 5055
            name           = "http"
          }
          volume_mount {
            name       = "data"
            mount_path = "/app/config"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jellyseerr_data.metadata.0.name
          }
        }
        volume {
          name = "settings"
          config_map {
            name = kubernetes_config_map.jellyseer_restore_db.metadata.0.name
            items {
              key  = "settings.json"
              path = "settings.json"
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

resource "kubernetes_persistent_volume_claim" "jellyseerr_data" {
  metadata {
    name      = "jellyseerr-data"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    storage_class_name = "nfs-csi-main"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "15Gi"
      }
    }
  }
}

resource "kubernetes_service" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "jellyseerr"
    }
    port {
      name        = "http"
      port        = 5055
      target_port = "http"
    }
  }
  depends_on = [
    kubernetes_deployment.jellyseerr
  ]
}


resource "kubernetes_manifest" "jellyseerr_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "jellyseerr"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "jellyseerr.home.spicedelver.me"
      tls = {
        secret = "jellyseerr-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "jellyseerr"
        service = kubernetes_service.jellyseerr.metadata.0.name
        port    = 5055
      }]
      routes = [{
        path = "/"
        action = {
          pass = "jellyseerr"
        }
      }]
    }
  }
}

# Public host, but external-dns does not manage its record: the old Ingress had no
# external-dns hostname annotation, so spec.externalDNS is deliberately unset.
resource "kubernetes_manifest" "jellyseerr_public_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "jellyseerr-public"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "jellyseerr.spicedelver.me"
      externalDNS = {
        enable = true
      }
      tls = {
        secret = "jellyseerr-public-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "jellyseerr"
        service = kubernetes_service.jellyseerr.metadata.0.name
        port    = 5055
      }]
      routes = [{
        path = "/"
        action = {
          pass = "jellyseerr"
        }
      }]
    }
  }
}

resource "kubernetes_config_map" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "LOG_LEVEL" = "debug"
    "TZ"        = local.timezone
  }
}

resource "kubernetes_config_map" "jellyseer_restore_db" {
  metadata {
    name      = "jellyseerr-restore-db"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "settings.json" = file("${path.module}/conf/jellyseer_settings.json")
  }
}
