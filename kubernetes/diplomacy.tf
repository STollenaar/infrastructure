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
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/diplomacy:client-0.0.1"
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
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/diplomacy:server-0.0.1"
          env {
            name  = "ConnectionStrings__Database"
            value = "Server=mssql.diplomacy.svc.cluster.local;Database=diplomacy;User=SA;Password=Passw0rd@;Encrypt=True;TrustServerCertificate=True"
          }
          port {
            container_port = 8080
            name           = "backend"
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


resource "kubernetes_stateful_set_v1" "mssql" {
  metadata {
    name      = "mssql"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    labels = {
      app = "mssql"
    }
  }
  spec {
    service_name = kubernetes_service_v1.mssql.metadata.0.name
    selector {
      match_labels = {
        app = "mssql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mssql"
        }
      }
      spec {
        container {
          name  = "mssql"
          image = "mcr.microsoft.com/mssql/server:2022-latest"
          env {
            name  = "ACCEPT_EULA"
            value = "y"
          }
          env {
            name  = "MSSQL_SA_PASSWORD"
            value = "Passw0rd@"
          }
          port {
            container_port = 1433
            name           = "mssql"
          }
          volume_mount {
            name       = "mssql-data"
            mount_path = "/var/opt/mssql/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "mssql-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "nfs-csi-other"
        resources {
          requests = {
            storage = "20Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mssql" {
  metadata {
    name      = "mssql"
    namespace = kubernetes_namespace_v1.diplomacy.metadata.0.name
    labels = {
      app = "mssql"
    }
  }
  spec {
    selector = {
      app = "mssql"
    }
    port {
      port        = 1433
      target_port = "mssql"
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
