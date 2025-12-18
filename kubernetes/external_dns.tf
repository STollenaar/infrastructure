resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

# Service Account
resource "kubernetes_service_account_v1" "external_dns_public" {
  metadata {
    name      = "external-dns-public"
    namespace = kubernetes_namespace_v1.external_dns.id
    labels = {
      "app.kubernetes.io/name" = "external-dns-public"
    }
  }
}

# Cluster Role
resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "pods", "nodes"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }
}

# Cluster Role Binding
resource "kubernetes_cluster_role_binding" "external_dns_viewer" {
  metadata {
    name = "external-dns-viewer"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.external_dns_public.metadata.0.name
    namespace = kubernetes_namespace_v1.external_dns.id
  }
}

# Deployment
resource "kubernetes_deployment" "external_dns_public" {
  metadata {
    name      = "external-dns-public"
    namespace = kubernetes_namespace_v1.external_dns.id
    labels = {
      "app.kubernetes.io/name" = "external-dns-public"
    }
  }

  spec {
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "external-dns-public"
      }
    }

    template {
      metadata {
        annotations = {
          "vault.hashicorp.com/agent-inject" = "true"
          "vault.hashicorp.com/role"         = "internal-app"
          "vault.hashicorp.com/aws-role"     = data.terraform_remote_state.aws_iam.outputs.iam_roles.external_dns_role.name
          "cache.spicedelver.me/cmtemplate"  = "vault-aws-agent"
        }
        labels = {
          "app.kubernetes.io/name" = "external-dns-public"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_manifest.external_dns_secret.manifest.spec.target.name
        }
        service_account_name = kubernetes_service_account_v1.external_dns_public.metadata.0.name

        container {
          name  = "external-dns-public"
          image = "registry.k8s.io/external-dns/external-dns:v0.20.0"

          args = [
            "--source=ingress",
            "--annotation-filter=external-dns.alpha.kubernetes.io/hostname",
            "--provider=webhook",
            "--webhook-provider-url=http://127.0.0.1:8889",
            "--registry=txt",
            "--txt-owner-id=${data.terraform_remote_state.route53.outputs.route53.id}",
          ]
          resources {
            requests = {
              cpu    = "10m"
              memory = "10Mi"
            }
            limits = {
              memory = "30Mi"
            }
          }
        }

        container {
          name              = "external-ip"
          image             = "${data.terraform_remote_state.ecr.outputs.external_ip_repo.repository_url}:latest"
          image_pull_policy = "Always"

          env {
            name  = "MODE"
            value = "checkip"
          }
          env {
            name  = "AWS_PROVIDER_URL"
            value = "http://127.0.0.1:8888"
          }
          env {
            name  = "LISTEN_ADDR"
            value = ":8889"
          }
          port {
            container_port = 8889
            name           = "webhook"
          }
          resources {
            requests = {
              cpu    = "10m"
              memory = "10Mi"
            }
            limits = {
              memory = "30Mi"
            }
          }
        }

        container {
          name  = "aws-provider"
          image = "registry.k8s.io/external-dns/external-dns:v0.20.0"

          args = [
            "--webhook-server",
            "--provider=aws",
            "--source=ingress",
            "--aws-zone-type=public",
            "--registry=txt",
            "--metrics-address=:7980",
            "--txt-owner-id=${data.terraform_remote_state.route53.outputs.route53.id}",
          ]
          port {
            container_port = 8888
            name           = "provider"
          }

          env {
            name  = "AWS_DEFAULT_REGION"
            value = "ca-central-1"
          }
          env {
            name  = "AWS_SHARED_CREDENTIALS_FILE"
            value = "/vault/secrets/aws/credentials"
          }
          resources {
            requests = {
              cpu    = "10m"
              memory = "10Mi"
            }
            limits = {
              memory = "30Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_cron_job_v1" "restart_external_dns" {
  metadata {
    name      = "restart-external-dns"
    namespace = kubernetes_namespace_v1.external_dns.id
  }

  spec {
    schedule = "0 * * * *" # every hour at minute 0
    # suspend = true
    successful_jobs_history_limit = 1
    failed_jobs_history_limit     = 1

    job_template {
      metadata {
        labels = {
          app = "restart-external-dns"
        }
      }
      spec {
        template {
          metadata {
            labels = {
              app = "restart-external-dns"
            }
          }
          spec {
            service_account_name = kubernetes_service_account_v1.restart_external_dns.metadata.0.name

            container {
              name  = "kubectl"
              image = "rancher/kubectl:v1.34.3"

              command = [
                "kubectl", "rollout", "restart",
                "deployment/${kubernetes_deployment.external_dns_public.metadata.0.name}",
                "-n", kubernetes_namespace_v1.external_dns.id
              ]
            }

            restart_policy = "Never"
          }
        }
      }
    }
  }
}

# ServiceAccount for the CronJob
resource "kubernetes_service_account_v1" "restart_external_dns" {
  metadata {
    name      = "restart-external-dns"
    namespace = kubernetes_namespace_v1.external_dns.id
  }
}

# Role allowing patch/update/get of the external-dns deployment
resource "kubernetes_role_v1" "restart_external_dns" {
  metadata {
    name      = "restart-external-dns"
    namespace = kubernetes_namespace_v1.external_dns.id
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "delete"]
  }
}

# RoleBinding linking the ServiceAccount to the Role
resource "kubernetes_role_binding_v1" "restart_external_dns" {
  metadata {
    name      = "restart-external-dns"
    namespace = kubernetes_namespace_v1.external_dns.id
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.restart_external_dns.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.restart_external_dns.metadata.0.name
    namespace = kubernetes_namespace_v1.external_dns.id
  }
}

resource "kubernetes_manifest" "external_dns_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace_v1.external_dns.metadata.0.name
    }
    spec = {
      secretStoreRef = {
        name = kubernetes_manifest.vault_backend.manifest.metadata.name
        kind = kubernetes_manifest.vault_backend.manifest.kind
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
