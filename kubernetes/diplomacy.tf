resource "kubernetes_namespace_v1" "diplomacy" {
  metadata {
    name = "diplomacy"
  }
}

resource "kubernetes_deployment_v1" "diplomacy_frontend" {
  metadata {
    name      = "diplomacy-frontend"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    labels = {
      app = "diplomacy-frontend"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "diplomacy-frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "diplomacy-frontend"
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_manifest.diplomacy_external_secret.manifest.spec.target.name
        }
        container {
          name  = "diplomacy-frontend"
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/diplomacy:client-0.0.2"
          port {
            container_port = 8080
            name           = "frontend"
          }
          volume_mount {
            name       = "frontend-caddy"
            mount_path = "/etc/Caddyfile"
            sub_path   = "Caddyfile"
          }
        }
        volume {
          name = "frontend-caddy"
          config_map {
            name = kubernetes_config_map.diplomacy_frontend.metadata.0.name
            items {
              key  = "Caddyfile"
              path = "Caddyfile"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "diplomacy_frontend" {
  metadata {
    name      = "diplomacy-frontend"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    labels = {
      app = "diplomacy-frontend"
    }
  }
  spec {
    selector = {
      app = "diplomacy-frontend"
    }
    port {
      port        = 8080
      name        = "frontend"
      target_port = "frontend"
    }
  }
}

resource "kubernetes_deployment_v1" "diplomacy_backend" {
  metadata {
    name      = "diplomacy-backend"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    labels = {
      app = "diplomacy-backend"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "diplomacy-backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "diplomacy-backend"
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_manifest.diplomacy_external_secret.manifest.spec.target.name
        }
        container {
          name  = "diplomacy-backend"
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/diplomacy:server-0.0.2"
          env {
            name  = "ConnectionStrings__Database"
            value = "Data Source=5dDiplomacy.db"
          }
          env {
            name = "Provider"
            value = "Sqlite"
          }
          port {
            container_port = 8080
            name           = "backend"
          }
          volume_mount {
            name = "database"
            mount_path = "/app/db"
          }
        }
        volume {
          name = "database"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.diplomacy_database.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "diplomacy_backend" {
  metadata {
    name      = "diplomacy-backend"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    labels = {
      app = "diplomacy-backend"
    }
  }
  spec {
    selector = {
      app = "diplomacy-backend"
    }
    port {
      port        = 8080
      target_port = "backend"
    }
  }
}


resource "kubernetes_persistent_volume_claim_v1" "diplomacy_database" {
  metadata {
    name      = "diplomacy-db"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        "storage" = "10Gi"
      }
    }
  }
}

resource "kubernetes_config_map" "diplomacy_frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
  }
  data = {
    Caddyfile = templatefile("${path.module}/conf/diplomacy-frontend.Caddyfile", {
      backend_url = "http://${kubernetes_service_v1.diplomacy_backend.metadata.0.name}.${kubernetes_namespace_v1.diplomacy.metadata.0.name}.svc.cluster.local:8080"
    })
  }
}

resource "kubernetes_manifest" "diplomacy_vault_backend" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "vault-backend"
      namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    }
    spec = {
      provider = {
        vault = {
          server  = "http://vault.${kubernetes_namespace.vault.metadata.0.name}.svc.cluster.local:8200"
          path    = "secret"
          version = "v2"
          auth = {
            kubernetes = {
              mountPath = "kubernetes"
              role      = "external-secrets"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "diplomacy_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    }
    spec = {
      secretStoreRef = {
        name = kubernetes_manifest.diplomacy_vault_backend.manifest.metadata.name
        kind = kubernetes_manifest.diplomacy_vault_backend.manifest.kind
      }
      target = {
        name = "regcred"
        template = {
          type          = "kubernetes.io/dockerconfigjson"
          mergePolicy   = "Replace"
          engineVersion = "v2"
        }
      }
      data = [
        {
          secretKey = ".dockerconfigjson"
          remoteRef = {
            key      = "ecr-auth"
            property = ".dockerconfigjson"
          }
        }
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "diplomacy" {
  metadata {
    name      = "diplomacy"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "diplomacy.home.spicedelver.me"
      ]
      secret_name = "diplomacy-tls"
    }
    rule {
      host = "diplomacy.home.spicedelver.me"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service_v1.diplomacy_frontend.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}
