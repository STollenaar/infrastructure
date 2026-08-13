# Space Engineers dedicated server.
#
# Space Engineers only ships a Windows dedicated server, so this runs the
# community image that wraps it in Wine: https://github.com/Devidian/docker-spaceengineers
#
# Bootstrap (one-time, manual):
#   1. On a Windows box, use the official "Space Engineers Dedicated Server" tool
#      to create a world/instance named "${local.spaceengineers_instance}".
#   2. Copy that instance directory into the "instances" PVC below at
#      /appdata/space-engineers/instances/ (e.g. via `kubectl cp`).
#   The container downloads the game binaries itself via steamcmd on first start.

locals {
  spaceengineers_instance = "SE"
  # Game server port (UDP). This is the native Space Engineers dedicated port.
  spaceengineers_game_port = 27016
  # Plugin/remote web interface port (TCP) exposed by the image.
  spaceengineers_web_port = 8080
}

resource "kubernetes_namespace_v1" "spaceengineers" {
  metadata {
    name = "spaceengineers"
  }
}

resource "kubernetes_deployment_v1" "spaceengineers" {
  metadata {
    name      = "spaceengineers"
    namespace = kubernetes_namespace_v1.spaceengineers.id
    labels = {
      app = "spaceengineers"
    }
  }
  spec {
    # Single replica only: the Windows dedicated server is not clusterable and
    # the game files / save data live on ReadWriteOnce volumes.
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "spaceengineers"
      }
    }
    template {
      metadata {
        labels = {
          app = "spaceengineers"
        }
      }
      spec {
        container {
          name  = "spaceengineers"
          image = "devidian/spaceengineers:winestaging"

          env {
            name  = "INSTANCE_NAME"
            value = local.spaceengineers_instance
          }
          # Only used by the image's healthcheck (server-list lookup). Playing the
          # game does not depend on it, so keep it local like the upstream compose.
          env {
            name  = "PUBLIC_IP"
            value = "127.0.0.1"
          }
          env {
            name  = "WINEDEBUG"
            value = "-all"
          }

          port {
            container_port = local.spaceengineers_game_port
            protocol       = "UDP"
            name           = "game"
          }
          port {
            container_port = local.spaceengineers_web_port
            protocol       = "TCP"
            name           = "web"
          }

          resources {
            requests = {
              cpu    = "2"
              memory = "4Gi"
            }
            limits = {
              cpu    = "4"
              memory = "8Gi"
            }
          }

          # Volume paths must not change; the image hardcodes them.
          volume_mount {
            name       = "game"
            mount_path = "/appdata/space-engineers/SpaceEngineersDedicated"
          }
          volume_mount {
            name       = "instances"
            mount_path = "/appdata/space-engineers/instances"
          }
          volume_mount {
            name       = "plugins"
            mount_path = "/appdata/space-engineers/plugins"
          }
          volume_mount {
            name       = "steam"
            mount_path = "/root/.steam"
          }
        }

        volume {
          name = "game"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.spaceengineers_game.metadata.0.name
          }
        }
        volume {
          name = "instances"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.spaceengineers_instances.metadata.0.name
          }
        }
        volume {
          name = "plugins"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.spaceengineers_plugins.metadata.0.name
          }
        }
        volume {
          name = "steam"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.spaceengineers_steam.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

# Game files downloaded by steamcmd (several GB) and the steam cache live on
# node-local storage: many small files + Windows file semantics under Wine
# behave poorly over NFS, and pinning to a node is fine for a single replica.
resource "kubernetes_persistent_volume_claim_v1" "spaceengineers_game" {
  metadata {
    name      = "spaceengineers-game"
    namespace = kubernetes_namespace_v1.spaceengineers.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "openebs-hostpath"
    resources {
      requests = {
        "storage" = "30Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "spaceengineers_instances" {
  metadata {
    name      = "spaceengineers-instances"
    namespace = kubernetes_namespace_v1.spaceengineers.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "openebs-hostpath"
    resources {
      requests = {
        "storage" = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "spaceengineers_plugins" {
  metadata {
    name      = "spaceengineers-plugins"
    namespace = kubernetes_namespace_v1.spaceengineers.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "openebs-hostpath"
    resources {
      requests = {
        "storage" = "2Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "spaceengineers_steam" {
  metadata {
    name      = "spaceengineers-steam"
    namespace = kubernetes_namespace_v1.spaceengineers.id
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "openebs-hostpath"
    resources {
      requests = {
        "storage" = "5Gi"
      }
    }
  }
}

# Game traffic is UDP. This stays a ClusterIP service; the ingress-nginx
# controller exposes it publicly via its udp-services map (see the `udp` block in
# conf/nginx-ingress-values.yaml), so it shares the controller's MetalLB IP
# instead of allocating a dedicated LoadBalancer IP.
resource "kubernetes_service_v1" "spaceengineers_game" {
  metadata {
    name      = "spaceengineers-game"
    namespace = kubernetes_namespace_v1.spaceengineers.id
    labels = {
      app = "spaceengineers"
    }
  }
  spec {
    selector = {
      app = "spaceengineers"
    }
    port {
      name        = "game"
      protocol    = "UDP"
      port        = local.spaceengineers_game_port
      target_port = "game"
    }
  }
}

# Plugin / remote web interface, reachable in-cluster and via the home ingress.
resource "kubernetes_service_v1" "spaceengineers_web" {
  metadata {
    name      = "spaceengineers-web"
    namespace = kubernetes_namespace_v1.spaceengineers.id
    labels = {
      app = "spaceengineers"
    }
  }
  spec {
    selector = {
      app = "spaceengineers"
    }
    port {
      name        = "web"
      protocol    = "TCP"
      port        = local.spaceengineers_web_port
      target_port = "web"
    }
  }
}

resource "kubernetes_manifest" "spaceengineers_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "spaceengineers"
      namespace = kubernetes_namespace_v1.spaceengineers.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "spaceengineers.home.spicedelver.me"
      tls = {
        secret = "spaceengineers-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "spaceengineers-web"
        service = kubernetes_service_v1.spaceengineers_web.metadata.0.name
        port    = local.spaceengineers_web_port
      }]
      routes = [{
        path = "/"
        action = {
          pass = "spaceengineers-web"
        }
      }]
    }
  }
}

# Raw UDP passthrough for the game port. This replaces the old ingress-nginx
# "udp-services" ConfigMap entry; the matching listener is declared in
# conf/nginx-ingress-values.yaml.
resource "kubernetes_manifest" "spaceengineers_game_transportserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "TransportServer"
    metadata = {
      name      = "spaceengineers-game"
      namespace = kubernetes_namespace_v1.spaceengineers.id
    }
    spec = {
      ingressClassName = "nginx"
      listener = {
        name     = "spaceengineers-game-udp"
        protocol = "UDP"
      }
      upstreams = [{
        name    = "spaceengineers-game"
        service = kubernetes_service_v1.spaceengineers_game.metadata.0.name
        port    = local.spaceengineers_game_port
      }]
      # The dedicated server holds long-lived UDP sessions; the NGINX default of
      # 10m would drop idle players mid-session.
      sessionParameters = {
        timeout = "60m"
      }
      action = {
        pass = "spaceengineers-game"
      }
    }
  }
}
