resource "kubernetes_secret" "vault_unseal_user" {
  metadata {
    name      = "vault-unseal"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  data = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.vault_unseal_user_key.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.vault_unseal_user_key.secret
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  version    = "0.28.0"
  namespace  = kubernetes_namespace.vault.metadata.0.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [templatefile("${path.module}/conf/values.yaml", {
    kms_key_id          = aws_kms_key.vault.key_id,
    vault_unseal_secret = kubernetes_secret.vault_unseal_user.metadata.0.name
    storage_class = "nfs-csi-other"
  })]
}

resource "kubernetes_job_v1" "vault_init" {
  depends_on = [helm_release.vault]
  metadata {
    name      = "vault-init"
    namespace = kubernetes_namespace.vault.metadata.0.name
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
          image   = "hashicorp/vault:1.16.1"
          command = ["sh", "-c", file("${path.module}/conf/vault-init.sh")]
          env {
            name  = "VAULT_ENDPOINT"
            value = "vault.${kubernetes_namespace.vault.metadata.0.name}.svc.cluster.local"
          }
          env {
            name  = "VAULT_PORT"
            value = "8200"
          }
          env {
            name  = "HCP_APP_NAME"
            value = hcp_vault_secrets_app.proxmox_vault.app_name
          }
          env {
            name  = "HCP_ORG_ID"
            value = hcp_vault_secrets_app.proxmox_vault.organization_id
          }
          env {
            name  = "HCP_PROJECT_ID"
            value = hcp_vault_secrets_app.proxmox_vault.project_id
          }
          env {
            name = "HCP_CLIENT_ID"
            value_from {
              secret_key_ref {
                key  = "clientID"
                name = kubernetes_secret.vault_auth.metadata.0.name
              }
            }
          }
          env {
            name = "HCP_CLIENT_SECRET"
            value_from {
              secret_key_ref {
                key  = "clientSecret"
                name = kubernetes_secret.vault_auth.metadata.0.name
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
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
}

resource "kubernetes_cron_job_v1" "vault_ecr_token" {
  metadata {
    name      = "vault-ecr-refresh"
    namespace = kubernetes_namespace.vault.metadata.0.name
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
              "vault.hashicorp.com/aws-role"                = aws_iam_role.vault_ecr.name
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
              image   = "amazon/aws-cli"
              command = ["bash", "-c", file("${path.module}/conf/vault-ecr.sh")]
              env {
                name  = "AWS_SHARED_CREDENTIALS_FILE"
                value = "/vault/secrets/aws/credentials"
              }
              env {
                name  = "VAULT_ADDR"
                value = "http://vault.${kubernetes_namespace.vault.metadata.0.name}.svc.cluster.local:8200"
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
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
}


resource "hcp_vault_secrets_app" "proxmox_vault" {
  app_name    = "proxmox"
  description = "Proxmox hosted Vault tokens"
}

resource "kubernetes_manifest" "vault_backend" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "vault-backend"
      namespace = kubernetes_namespace.vault.metadata.0.name
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

resource "kubernetes_manifest" "external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = aws_iam_role.vault_ecr.name
      namespace = kubernetes_namespace.vault.metadata.0.name
    }
    spec = {
      secretStoreRef = {
        name = "vault-backend"
        kind = "SecretStore"
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
            key      = aws_iam_role.vault_ecr.name
            property = ".dockerconfigjson"
          }
        }
      ]
    }
  }
}
