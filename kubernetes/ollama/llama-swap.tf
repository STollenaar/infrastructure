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

  # Image generation (the qwen-image-2.1-turbo model below): Qwen-Image 2.1 Turbo
  # (Sep 2026), an 8-step distill of Qwen-Image 2.1, with its Qwen3-VL text encoder
  # and VAE as recommended on the unsloth model card. ~13 GiB in total.
  sd_files = {
    diffusion = {
      name = "qwen-image-2.1-turbo-Q8_0.gguf"
      src  = "unsloth/Qwen-Image-2.1-Turbo-GGUF/resolve/main/qwen-image-2.1-turbo-Q8_0.gguf"
    }
    vae = {
      name = "qwen_image_2.1_vae_bf16.safetensors"
      src  = "unsloth/Qwen-Image-2.1-FP8/resolve/main/vae/qwen_image_2.1_vae_bf16.safetensors"
    }
    llm = {
      name = "Qwen3-VL-8B-Instruct-UD-Q4_K_XL.gguf"
      src  = "unsloth/Qwen3-VL-8B-Instruct-GGUF/resolve/main/Qwen3-VL-8B-Instruct-UD-Q4_K_XL.gguf"
    }
  }

  # sd-server cannot pull from Hugging Face itself (unlike llama-server's -hf), so
  # an init container fetches these onto the sd-models PVC if they are not there
  # yet. Re-runs are no-ops.
  sd_fetch_script = join("\n", concat(
    [for f in local.sd_files : "[ -s /models/${f.name} ] || { curl -fL --retry 3 -o /models/${f.name}.part https://huggingface.co/${f.src} && mv /models/${f.name}.part /models/${f.name}; }"],
    # sd-server scans its model roots for LoRAs / upscalers when these are not
    # given; point them at empty dirs so it doesn't walk the filesystem.
    ["mkdir -p /models/loras /models/upscalers"],
  ))
}

# Weights for the qwen-image-2.1-turbo model. Predates llama-swap hosting sd-server
# (it belonged to a standalone stable-diffusion deployment), hence the name/label.
resource "kubernetes_persistent_volume_claim_v1" "sd_models_pvc" {
  metadata {
    name      = "sd-models"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
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

      models = merge({
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
        }, {
        # Image generation runs here rather than as its own deployment so that
        # llama-swap is the single scheduler for the card. Its default routing runs
        # one model at a time, and the FIFO scheduler parks a request that would
        # evict a model still serving one until that model drains - so a chat and an
        # image request arriving together are served one after the other instead of
        # both trying to fit in VRAM. That is what lets the weights live on the GPU
        # (no --offload-to-cpu). sd-server ships in the unified-vulkan image.
        "qwen-image-2.1-turbo" = {
          proxy = "http://127.0.0.1:$${PORT}"
          # sd-server has no /health; /v1/models answers once the model is loaded.
          checkEndpoint = "/v1/models"
          # sd-server serves its one model under this fixed id.
          useModelName = "sd-cpp-local"
          cmd = join(" ", [
            "sd-server",
            "--listen-ip 127.0.0.1",
            "--listen-port $${PORT}",
            "--diffusion-model /models/${local.sd_files.diffusion.name}",
            "--vae /models/${local.sd_files.vae.name}",
            "--llm /models/${local.sd_files.llm.name}",
            "--lora-model-dir /models/loras",
            "--hires-upscalers-dir /models/upscalers",
            # Turbo is distilled for 8 steps at CFG 1.
            "--steps 8",
            "--cfg-scale 1.0",
            "--sampling-method euler",
          ])
        }
    }) })
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

        # Stage the image-generation weights for the qwen-image-2.1-turbo entry;
        # sd-server cannot pull from Hugging Face itself. Re-runs are no-ops.
        init_container {
          name    = "fetch-sd-models"
          image   = "curlimages/curl:8.11.1"
          command = ["/bin/sh", "-ec"]
          args    = [local.sd_fetch_script]

          volume_mount {
            name       = "sd-models"
            mount_path = "/models"
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
          volume_mount {
            name       = "sd-models"
            mount_path = "/models"
          }
        }

        volume {
          name = "sd-models"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.sd_models_pvc.metadata.0.name
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
