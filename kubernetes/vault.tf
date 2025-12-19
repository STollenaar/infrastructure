locals {
  vault_image_version = "1.19.0"
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  version    = "1.1.1"
  namespace  = kubernetes_namespace.vault.id
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  set = [
    {
      name  = "resources.requests.memory"
      value = "30Mi"
    },
    {
      name  = "resources.limits.memory"
      value = "90Mi"
    },
    {
      name  = "resources.requests.cpu"
      value = "10m"
    },
    {
      name  = "webhook.resources.requests.memory"
      value = "30Mi"
    },
    {
      name  = "webhook.resources.limits.memory"
      value = "90Mi"
    },
    {
      name  = "webhook.resources.requests.cpu"
      value = "10m"
    },
    {
      name  = "certController.resources.requests.memory"
      value = "40Mi"
    },
    {
      name  = "certController.resources.limits.memory"
      value = "90Mi"
    },
    {
      name  = "certController.resources.requests.cpu"
      value = "10m"
    },
  ]
}

resource "kubernetes_secret" "vault_unseal_user" {
  metadata {
    name      = "vault-unseal"
    namespace = kubernetes_namespace.vault.id
  }
  data = {
    AWS_ACCESS_KEY_ID     = data.aws_ssm_parameter.vault_user_access_key.value
    AWS_SECRET_ACCESS_KEY = data.aws_ssm_parameter.vault_user_secret_access_key.value
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  version    = "0.31.0"
  namespace  = kubernetes_namespace.vault.id
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [templatefile("${path.module}/conf/vault-values.yaml", {
    kms_key_id          = aws_kms_key.vault.key_id,
    vault_unseal_secret = kubernetes_secret.vault_unseal_user.metadata.0.name
    storage_class       = "nfs-csi-main"
    vault_image_version = local.vault_image_version
  })]
}

resource "kubernetes_job_v1" "vault_init" {
  depends_on = [helm_release.vault]
  metadata {
    name      = "vault-init"
    namespace = kubernetes_namespace.vault.id
    labels = {
      app = "vault-init"
    }
  }
  spec {
    backoff_limit = 2
    template {
      metadata {
        labels = {
          app = "vault-init"
        }
      }
      spec {
        container {
          name    = "vault-init"
          image   = "hashicorp/vault:${local.vault_image_version}"
          command = ["sh", "-c", file("${path.module}/conf/vault-init.sh")]
          env {
            name  = "VAULT_ENDPOINT"
            value = "vault.${kubernetes_namespace.vault.id}.svc.cluster.local"
          }
          env {
            name  = "VAULT_PORT"
            value = "8200"
          }
          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                key  = "AWS_ACCESS_KEY_ID"
                name = kubernetes_secret.vault_unseal_user.metadata.0.name
              }
            }
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                key  = "AWS_SECRET_ACCESS_KEY"
                name = kubernetes_secret.vault_unseal_user.metadata.0.name
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 7

  tags = {
    Name = "vault-kms-unseal-key"
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/vault-kms-unseal-key"
  target_key_id = aws_kms_key.vault.key_id
}

resource "kubernetes_service_account_v1" "internal_app_sa" {
  metadata {
    name      = "internal-app"
    namespace = kubernetes_namespace.vault.id
  }
}

resource "kubernetes_cron_job_v1" "vault_ecr_token" {
  metadata {
    name      = "vault-ecr-refresh"
    namespace = kubernetes_namespace.vault.id
  }
  spec {
    failed_jobs_history_limit     = 5
    successful_jobs_history_limit = 1
    schedule                      = "0 * * * *"
    job_template {
      metadata {
        labels = {
          app = "vault-ecr-refresh"
        }
      }
      spec {
        template {
          metadata {
            annotations = {
              "vault.hashicorp.com/agent-inject"            = "true"
              "vault.hashicorp.com/role"                    = "internal-app"
              "vault.hashicorp.com/aws-role"                = data.terraform_remote_state.aws_iam.outputs.iam_roles.vault_ecr_role.name
              "vault.hashicorp.com/agent-cache-enable"      = "true"
              "vault.hashicorp.com/agent-pre-populate-only" = "true"
              "cache.spicedelver.me/cmtemplate"             = "vault-aws-agent"
            }
            labels = {
              app = "vault-ecr-refresh"
            }
          }
          spec {
            service_account_name = kubernetes_service_account_v1.internal_app_sa.metadata.0.name
            container {
              name    = "ecr-refresher"
              image   = "amazon/aws-cli:2.32.21"
              command = ["bash", "-c", file("${path.module}/conf/vault-ecr.sh")]
              env {
                name  = "AWS_SHARED_CREDENTIALS_FILE"
                value = "/vault/secrets/aws/credentials"
              }
              env {
                name  = "VAULT_ADDR"
                value = "http://vault.${kubernetes_namespace.vault.id}.svc.cluster.local:8200"
              }
              env {
                name  = "ECR_REPO"
                value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ca-central-1.amazonaws.com"
              }
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      spec[0].suspend
    ]
  }
}

resource "kubernetes_cluster_role" "vault_authorizer" {
  metadata {
    name = "vault-authorizer"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "serviceaccounts/token"]
    verbs      = ["create", "update", "delete"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["rolebindings", "clusterrolebindings"]
    verbs      = ["create", "update", "delete"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "clusterroles"]
    verbs      = ["bind", "escalate", "create", "update", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "vault-token-creator-binding" {
  metadata {
    name = "vault-token-creator-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vault_authorizer.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "vault"
    namespace = kubernetes_namespace.vault.id
  }
}

resource "kubernetes_manifest" "vault_backend" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "vault-backend"
    }
    spec = {
      provider = {
        vault = {
          server  = "http://vault.${kubernetes_namespace.vault.id}.svc.cluster.local:8200"
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

resource "kubernetes_manifest" "external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "vault-ecr"
      namespace = kubernetes_namespace.vault.id
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
