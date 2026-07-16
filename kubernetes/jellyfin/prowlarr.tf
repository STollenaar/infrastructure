resource "kubernetes_deployment" "prowlarr" {
  depends_on = [kubernetes_job_v1.prowlarr_init]
  metadata {
    name      = "prowlarr"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "prowlarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "prowlarr"
      }
    }

    template {
      metadata {
        annotations = {
          "configmap-hash" = sha256(jsonencode(kubernetes_config_map.prowlarr_custom_indexers.data))
        }
        labels = {
          "app" = "prowlarr"
        }
      }

      spec {
        init_container {
          name  = "init-config"
          image = "busybox:1.38.0"
          args = [
            "/bin/sh",
            "-c",
            file("${path.module}/conf/copyConfig.sh")
          ]
          env {
            name  = "DESTINATION"
            value = "/config/config.xml"
          }
          env {
            name  = "SOURCE"
            value = "/tmp/config.xml"
          }

          volume_mount {
            name       = "config"
            mount_path = "/tmp/config.xml"
            sub_path   = "config.xml"
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
        }

        container {
          image = "ghcr.io/linuxserver/prowlarr:2.3.0"
          name  = "prowlarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.prowlarr_env.metadata.0.name
            }
          }
          port {
            container_port = 9696
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "custom-indexers"
            mount_path = "/config/Definitions/Custom"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.prowlarr_cm.metadata.0.name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.prowlarr_data.metadata.0.name
          }
        }
        volume {
          name = "custom-indexers"
          config_map {
            name = kubernetes_config_map.prowlarr_custom_indexers.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_persistent_volume_claim" "prowlarr_data" {
  metadata {
    name      = "prowlarr-data"
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

resource "kubernetes_service" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = kubernetes_namespace.jellyfin.id
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "prowlarr"
    }
    port {
      port = 9696
    }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}

resource "kubernetes_config_map" "prowlarr_env" {
  metadata {
    name      = "prowlarr-env"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "PUID" = 1000
    "PGID" = 1000
    "TZ"   = local.timezone
  }
}

resource "kubernetes_config_map" "prowlarr_cm" {
  metadata {
    name      = "prowlarr-config"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = {
    "config.xml" = templatefile("${path.module}/conf/prowlarr_config.xml", {
      postgres_host = "postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local"
    })
  }
}

resource "kubernetes_config_map" "prowlarr_custom_indexers" {
  metadata {
    name      = "prowlarr-custom-indexers"
    namespace = kubernetes_namespace.jellyfin.id
  }
  data = { for f in fileset("${path.module}/conf/prowlarrCustomIndexers", "*") : f => templatefile("${path.module}/conf/prowlarrCustomIndexers/${f}", {
    proxy = "${kubernetes_service.byparr.metadata.0.name}.${kubernetes_namespace.jellyfin.id}.svc.cluster.local:8889"
  }) }
}

resource "kubernetes_job_v1" "prowlarr_init" {
  depends_on = [kubernetes_manifest.cnpg_cluster]
  metadata {
    name      = "prowlarr-init"
    namespace = kubernetes_namespace.jellyfin.id
    labels = {
      "app" = "prowlarr"
    }
  }
  spec {
    template {
      metadata {
        labels = {
          app = "prowlarr-init"
        }
      }
      spec {
        container {
          name    = "prowlarr-main"
          image   = "postgres:18.4-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'prowlarr-main'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres prowlarr-main"
          ]
          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
        container {
          name    = "prowlarr-logs"
          image   = "postgres:18.4-bookworm"
          command = ["/bin/sh", "-c"]
          args = [
            "psql -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'prowlarr-logs'\" | grep -q 1 || createdb -h postgres-rw.${kubernetes_namespace.jellyfin.id}.svc.cluster.local -U postgres prowlarr-logs"
          ]
          env {
            name  = "PGPASSWORD"
            value = "password"
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.image,
      spec.0.template.0.spec.0.container.1.image
    ]
  }
}

resource "kubernetes_manifest" "prowlarr_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "prowlarr"
      namespace = kubernetes_namespace.jellyfin.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "prowlarr.home.spicedelver.me"
      tls = {
        secret = "prowlarr-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "prowlarr"
        service = kubernetes_service.prowlarr.metadata.0.name
        port    = 9696
      }]
      routes = [{
        path = "/"
        action = {
          pass = "prowlarr"
        }
      }]
    }
  }
}
