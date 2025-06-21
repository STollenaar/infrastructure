resource "kubernetes_namespace_v1" "renovate" {
  metadata {
    name = "renovate"
  }
}
resource "kubernetes_config_map" "renovate_config" {
  metadata {
    name      = "renovate-config"
    namespace = kubernetes_namespace_v1.renovate.metadata.0.name
  }

  data = {
    "config.json" = jsonencode({
      repositories = ["STollenaar/infrastructure"]
      dryRun       = "full"
    })
  }
}

resource "kubernetes_secret" "github_renovate_token" {
  metadata {
    name      = "renovate"
    namespace = kubernetes_namespace_v1.renovate.metadata.0.name
  }
  data = {
    RENOVATE_TOKEN = data.aws_ssm_parameter.github_renovate.value
  }
}

resource "kubernetes_cron_job_v1" "renovate_bot" {
  metadata {
    name      = "renovate-bot"
    namespace = kubernetes_namespace_v1.renovate.metadata.0.name
  }

  spec {
    schedule           = "@hourly"
    concurrency_policy = "Forbid"
    suspend            = true # Paused state

    job_template {
      metadata {
        labels = {
          app = "renovate"
        }
      }
      spec {
        template {
          metadata {
            labels = {
              app = "renovate"
            }
          }
          spec {
            restart_policy = "Never"
            image_pull_secrets {
              name = kubernetes_manifest.renovate_external_secret.manifest.spec.target.name
            }

            container {
              name              = "renovate-bot"
              image             = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/renovate:latest"
              image_pull_policy = "Always"

              env {
                name  = "RENOVATE_PLATFORM"
                value = "github"
              }
              env_from {
                secret_ref {
                  name = kubernetes_secret.github_renovate_token.metadata.0.name
                }
              }
              env {
                name  = "RENOVATE_AUTODISCOVER"
                value = "false"
              }

              env {
                name  = "RENOVATE_BASE_DIR"
                value = "/tmp/renovate/"
              }

              env {
                name  = "RENOVATE_CONFIG_FILE"
                value = "/opt/renovate/config.json"
              }

              env {
                name  = "LOG_LEVEL"
                value = "debug"
              }

              volume_mount {
                name       = "config-volume"
                mount_path = "/opt/renovate/"
              }

              volume_mount {
                name       = "work-volume"
                mount_path = "/tmp/renovate/"
              }
            }

            volume {
              name = "config-volume"

              config_map {
                name = kubernetes_config_map.renovate_config.metadata[0].name
              }
            }

            volume {
              name = "work-volume"
              empty_dir {}
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_manifest" "renovate_vault_backend" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name      = "vault-backend"
      namespace = kubernetes_namespace_v1.renovate.metadata.0.name
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

resource "kubernetes_manifest" "renovate_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace_v1.renovate.metadata.0.name
    }
    spec = {
      secretStoreRef = {
        name = kubernetes_manifest.renovate_vault_backend.manifest.metadata.name
        kind = kubernetes_manifest.renovate_vault_backend.manifest.kind
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
