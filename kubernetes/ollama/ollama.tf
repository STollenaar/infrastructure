resource "kubernetes_namespace" "ollama" {
  metadata {
    name = "ollama"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "ollama_pvc" {
  metadata {
    name      = "ollama-cache"
    namespace = kubernetes_namespace.ollama.id
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "60Gi"
      }
    }
  }
}

# Superseded by llama-swap + llama.cpp (llama-swap.tf), which reaches the Intel GPU
# through Vulkan without a custom image and gives LiteLLM the same three model names.
#
# Scaled to 0 rather than deleted so this is one line away from coming back while the
# llama.cpp path is still unproven. It must stay at 0 whenever llama-swap is running:
# both mount the same ReadWriteOnce cache PVC, and both would claim a gpu.intel.com/xe
# slot. Note the image here is the ECR ollama-intel build (ollama/ollama plus
# mesa-vulkan-drivers) - stock ollama/ollama cannot see an Intel GPU at all.
resource "kubernetes_deployment" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "ollama"
    }
  }

  spec {
    replicas = 0
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "ollama"
      }
    }

    template {
      metadata {
        labels = {
          app = "ollama"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "intel.com/gpu.present"
                  operator = "In"
                  values   = ["true"]
                }
              }
            }
          }
        }

        # No runtime_class_name: "nvidia" existed only to swap in the NVIDIA
        # container runtime, which injected the CUDA userspace. Intel needs nothing
        # equivalent - the device plugin passes /dev/dri through and Mesa lives in
        # the image - so the default runtime is correct here.

        image_pull_secrets {
          name = kubernetes_manifest.ollama_external_secret.manifest.spec.target.name
        }

        container {
          name = "ollama"
          # Built from docker/ollama-intel: ollama/ollama plus mesa-vulkan-drivers.
          # The official image has the Vulkan backend compiled in but no Vulkan
          # driver, so on its own it enumerates no GPU and quietly runs on CPU.
          image = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/ollama-intel:0.40.8"
          args  = ["serve"]

          env {
            name  = "OLLAMA_MODEL"
            value = "mistral"
          }

          env {
            name  = "OLLAMA_NEW_ENGINE"
            value = "1"
          }

          # Kill switch if the Vulkan path misbehaves: set to 0 to ignore every
          # Vulkan GPU and fall back to CPU without changing anything else.
          env {
            name  = "OLLAMA_VULKAN"
            value = "1"
          }

          security_context {
            capabilities {
              # Without CAP_PERFMON (or root), Vulkan will not report free VRAM and
              # ollama's scheduler falls back to guessing model sizes, which on a
              # card this size means bad layer-offload decisions.
              add = ["PERFMON"]
            }
          }

          resources {
            limits = {
              memory             = "8Gi"
              "gpu.intel.com/xe" = 1
            }
            requests = {
              memory             = "6Gi"
              "gpu.intel.com/xe" = 1
            }
          }

          volume_mount {
            name       = "ollama-cache"
            mount_path = "/root/.ollama"
          }


          port {
            container_port = 11434
          }
        }

        volume {
          name = "ollama-cache"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ollama_pvc.metadata.0.name
          }
        }
      }
    }
  }
}



# Disabled with ollama: `ollama create` needs a running ollama server, and the
# Modelfile concept it exists to apply has no equivalent in llama.cpp. The modelfile
# in conf/ollama is kept as the source of the mistral-summary system prompt, which
# now needs re-homing (see conf/litellm/config.yaml).
resource "kubernetes_job" "ollama_model_creation" {
  count = 0

  depends_on = [kubernetes_deployment.ollama]

  metadata {
    name      = "ollama-model-creation"
    namespace = kubernetes_namespace.ollama.id
  }

  spec {
    template {
      metadata {
        labels = {
          job                                      = "ollama-model-creation"
          "checksum/configmap-mistral-model-files" = kubernetes_config_map.ollama_models.metadata.0.resource_version
        }
      }

      spec {
        container {
          name  = "ollama"
          image = "ollama/ollama:0.40.13"

          command = [
            "/bin/sh",
            "-c",
          ]
          args = [
            <<EOF
                for file in /modelfiles/*.modelfile; do
                    model_name=$(basename "$file" .modelfile)
                    ollama create "$model_name" -f "$file"
                done
            EOF

          ]

          env {
            name  = "OLLAMA_HOST"
            value = "${kubernetes_service.ollama.metadata.0.name}.${kubernetes_namespace.ollama.id}:11434"
          }

          volume_mount {
            name       = "ollama-models"
            mount_path = "/modelfiles"
          }
        }

        restart_policy = "Never"

        volume {
          name = "ollama-models"
          config_map {
            name = kubernetes_config_map.ollama_models.metadata.0.name
          }
        }
      }
    }

    backoff_limit = 4
  }
  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.image
    ]
  } 
}

resource "kubernetes_config_map" "ollama_models" {
  metadata {
    name      = "ollama-models"
    namespace = kubernetes_namespace.ollama.id
  }
  data = { for f in fileset("${path.module}/conf/ollama", "*") : f => file("${path.module}/conf/ollama/${f}") }
}

resource "kubernetes_service" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.ollama.id
  }

  spec {
    selector = {
      app = "ollama"
    }

    port {
      port        = 11434
      target_port = 11434
    }
  }
}

resource "kubernetes_manifest" "ollama_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace.ollama.id
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
