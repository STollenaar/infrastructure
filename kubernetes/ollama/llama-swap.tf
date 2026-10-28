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

  # Quants verified to exist in these repos. Each is pulled on first use by
  # llama-server's -hf flag and cached on the PVC, so nothing has to be staged by hand.
  # Sized for the 24 GB Arc Pro B60; llama-swap keeps one loaded at a time.
  llama_models = {
    # General chat / instructions. Dense 27B (Aug 2026); UD-Q4_K_XL is 16.35 GiB,
    # leaving room for 32K context. Reasoning left on the template default.
    "qwen3.8-27b" = {
      repo = "unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL"
      ctx  = 32768
      args = []
    }
    # Summarisation. Small and fast enough to chew through chat logs; Q6_K is
    # 6.95 GiB and near-lossless. Thinking is turned off: it only adds latency
    # and stray text to what should be a straight JSON answer.
    "qwen3.5-9b" = {
      repo = "unsloth/Qwen3.5-9B-GGUF:Q6_K"
      ctx  = 32768
      args = ["--reasoning off"]
    }
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
        for name, m in local.llama_models : name => {
          proxy = "http://127.0.0.1:$${PORT}"
          cmd = join(" ", concat([
            "llama-server",
            "--host 127.0.0.1",
            "--port $${PORT}",
            "-hf ${m.repo}",
            # These repos ship a vision projector that -hf would otherwise pull and
            # load; nothing here sends images, so skip the extra ~0.9 GB of VRAM.
            "--no-mmproj",
            # Offload everything the card will take.
            "--n-gpu-layers 999",
            "--ctx-size ${m.ctx}",
            "--jinja",
          ], m.args))
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
              # Room for the 16 GiB 27B GGUF passing through host memory on load.
              memory             = "20Gi"
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
            # Reuses the NFS cache ollama was using. Reads top out at ~117 MB/s (the
            # 1 GbE link), so a cold load of the 16 GB 27B takes ~150 s before the
            # first token - on pod start and on every swap between models. Node-local
            # storage (~2.5 GB/s) would fix that once the node has the disk space.
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
