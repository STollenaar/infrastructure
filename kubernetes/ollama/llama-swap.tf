# llama.cpp behind llama-swap, replacing ollama as LiteLLM's backend.
#
# Why llama-swap and not llama-server on its own: llama-server holds exactly one
# model per process, while ollama loaded and unloaded on demand. llama-swap is an
# OpenAI-compatible proxy that starts and stops a llama-server per requested model,
# which restores that behaviour on a single card. LiteLLM talks to llama-swap and
# never knows a swap happened.
#
# Why the vulkan image and not SYCL: ollama can only reach Intel GPUs through
# Vulkan, but llama.cpp also has a SYCL backend (ghcr.io/ggml-org/llama.cpp:server-intel)
# which is usually faster on Arc. It is deliberately not used here, because SYCL pulls
# in Intel's oneAPI runtime and this node's CPU is a masked qemu64 that reports no AVX
# - exactly how the earlier vLLM attempt died ("UCX library was compiled with avx but
# CPU does not support it"). Vulkan has no oneAPI dependency, so it is the safe default.
# Once the Proxmox VM's CPU type is switched to `host`, swapping local.llama_image to
# a SYCL build is a one-line change.
#
# The image already carries the Intel Vulkan driver: /usr/share/vulkan/icd.d in
# ghcr.io/mostlygeek/llama-swap:unified-vulkan contains intel_icd.json. That is the
# piece the official ollama image lacks, which is why this route needs no custom build.

locals {
  # unified-vulkan bundles llama-swap + a Vulkan llama-server + mesa's ICDs.
  llama_image = "ghcr.io/mostlygeek/llama-swap:unified-vulkan"

  # Quants verified to exist in these repos. Both are pulled on first use by
  # llama-server's -hf flag and cached on the PVC, so nothing has to be staged by hand.
  llama_models = {
    "mistral"     = "bartowski/Mistral-7B-Instruct-v0.3-GGUF:Q4_K_M"
    "llama3.2-3b" = "bartowski/Llama-3.2-3B-Instruct-GGUF:Q4_K_M"
  }
}

resource "kubernetes_config_map_v1" "llama_swap_config" {
  metadata {
    name      = "llama-swap-config"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "llama-swap"
    }
  }

  data = {
    # Built with yamlencode rather than a heredoc template: a %{for} directive
    # interacts badly with <<-EOT's dedent and silently produced model keys indented
    # deeper than their own children, which is invalid YAML. yamlencode cannot emit
    # malformed YAML.
    #
    # Schema follows llama-swap's own docker/config.example.yaml: top-level
    # healthCheckTimeout/logRequests, then a models map of proxy + cmd.
    #
    # No `ttl` key here on purpose - it is described in the README but appears in
    # neither shipped example, and an unrecognised key would stop llama-swap from
    # starting. The default swap-on-demand already unloads the previous model when a
    # different one is asked for, which is the behaviour that matters on one GPU.
    #
    # $${PORT} is escaped so Terraform leaves it for llama-swap to substitute.
    "config.yaml" = yamlencode({
      # A cold cache means the -hf download happens inside the health check window.
      healthCheckTimeout = 900
      logRequests        = true

      models = {
        for name, repo in local.llama_models : name => {
          proxy = "http://127.0.0.1:$${PORT}"
          cmd = join(" ", [
            "llama-server",
            "--host 127.0.0.1",
            "--port $${PORT}",
            "-hf ${repo}",
            # Offload everything the card will take; Arc has far more VRAM than the
            # 4 GB GTX 980 this replaced.
            "--n-gpu-layers 999",
            "--ctx-size 8192",
            "--jinja",
          ])
        }
      }
    })
  }
}

resource "kubernetes_deployment" "llama_swap" {
  metadata {
    name      = "llama-swap"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "llama-swap"
    }
  }

  spec {
    replicas = 1

    # One GPU and one model cache volume; never run two copies at once.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "llama-swap"
      }
    }

    template {
      metadata {
        labels = {
          app = "llama-swap"
        }
        annotations = {
          "checksum/config" = sha256(kubernetes_config_map_v1.llama_swap_config.data["config.yaml"])
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

        container {
          name  = "llama-swap"
          image = local.llama_image

          # run.sh turns LLAMA_SWAP_* into flags; point it at the mounted config
          # rather than the example baked into the image.
          env {
            name  = "LLAMA_SWAP_CONFIG"
            value = "/etc/llama-swap/config/config.yaml"
          }
          # Keep -hf downloads on the PVC instead of the container filesystem.
          env {
            name  = "HF_HOME"
            value = "/cache/huggingface"
          }

          port {
            name           = "http"
            container_port = 8080
          }

          resources {
            limits = {
              memory             = "12Gi"
              "gpu.intel.com/xe" = 1
            }
            requests = {
              memory             = "8Gi"
              "gpu.intel.com/xe" = 1
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/llama-swap/config"
          }
          volume_mount {
            name       = "cache"
            mount_path = "/cache"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.llama_swap_config.metadata[0].name
          }
        }
        volume {
          name = "cache"
          persistent_volume_claim {
            # Reuses the cache ollama was using. 10Gi is tight for several GGUFs -
            # the two Q4_K_M quants above are roughly 4.4 GB and 2 GB.
            claim_name = kubernetes_persistent_volume_claim.ollama_pvc.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "llama_swap" {
  metadata {
    name      = "llama-swap"
    namespace = kubernetes_namespace.ollama.id
  }

  spec {
    selector = {
      app = "llama-swap"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}
