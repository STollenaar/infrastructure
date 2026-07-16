resource "kubernetes_namespace_v1" "diplomacy" {
  metadata {
    name = "diplomacy"
  }
}

resource "kubernetes_deployment_v1" "diplomacy_frontend" {
  metadata {
    name      = "diplomacy-frontend"
    namespace = kubernetes_namespace_v1.diplomacy.id
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
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/diplomacy:client-0.0.3"
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
    namespace = kubernetes_namespace_v1.diplomacy.id
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
    namespace = kubernetes_namespace_v1.diplomacy.id
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
          image = "${var.ecr_repositories.diplomacy_repo}:server-0.0.3"
          env {
            name  = "ConnectionStrings__Database"
            value = "Data Source=5dDiplomacy.db"
          }
          env {
            name  = "Provider"
            value = "Sqlite"
          }
          port {
            container_port = 8080
            name           = "backend"
          }
          volume_mount {
            name       = "database"
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
    namespace = kubernetes_namespace_v1.diplomacy.id
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
    namespace = kubernetes_namespace_v1.diplomacy.id
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
    namespace = kubernetes_namespace_v1.diplomacy.id
  }
  data = {
    Caddyfile = templatefile("${path.module}/conf/diplomacy-frontend.Caddyfile", {
      backend_url = "http://${kubernetes_service_v1.diplomacy_backend.metadata.0.name}.${kubernetes_namespace_v1.diplomacy.id}.svc.cluster.local:8080"
    })
  }
}

resource "kubernetes_manifest" "diplomacy_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace_v1.diplomacy.id
    }
    spec = {
      secretStoreRef = {
        name = var.vault_backend.name
        kind = var.vault_backend.kind
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

resource "kubernetes_manifest" "diplomacy_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "diplomacy"
      namespace = kubernetes_namespace_v1.diplomacy.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "diplomacy.home.spicedelver.me"
      tls = {
        secret = "diplomacy-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "diplomacy-frontend"
        service = kubernetes_service_v1.diplomacy_frontend.metadata.0.name
        port    = 8080
      }]
      routes = [{
        path = "/"
        action = {
          pass = "diplomacy-frontend"
        }
      }]
    }
  }
}

// The NGINX Ingress Controller basicAuth policy requires the nginx.org/htpasswd
// secret type with the htpasswd file under the "htpasswd" key, rather than the
// Opaque/"auth" layout that ingress-nginx expected. The SSM value itself is an
// unchanged htpasswd file.
resource "kubernetes_secret_v1" "diplomacy_basic_auth" {
  metadata {
    name      = "diplomacy-basic-auth"
    namespace = kubernetes_namespace_v1.diplomacy.id
  }

  data = {
    "htpasswd" = data.aws_ssm_parameter.diplomacy_auth.value
  }

  type = "nginx.org/htpasswd"
}

resource "kubernetes_manifest" "diplomacy_basic_auth_policy" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "Policy"
    metadata = {
      name      = "diplomacy-basic-auth"
      namespace = kubernetes_namespace_v1.diplomacy.id
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret_v1.diplomacy_basic_auth.metadata.0.name
        realm  = "Authentication Required"
      }
    }
  }
}


# Public host, but external-dns does not manage its record: the old Ingress had no
# external-dns hostname annotation, so spec.externalDNS is deliberately unset.
resource "kubernetes_manifest" "diplomacy_public_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "diplomacy-public"
      namespace = kubernetes_namespace_v1.diplomacy.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "diplomacy.spicedelver.me"
      policies = [{
        name = kubernetes_manifest.diplomacy_basic_auth_policy.manifest.metadata.name
      }]
      tls = {
        secret = "diplomacy-tls-public"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "diplomacy-frontend"
        service = kubernetes_service_v1.diplomacy_frontend.metadata.0.name
        port    = 8080
      }]
      routes = [{
        path = "/"
        action = {
          pass = "diplomacy-frontend"
        }
      }]
    }
  }
}
