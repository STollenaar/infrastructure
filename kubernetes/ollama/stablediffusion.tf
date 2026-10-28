locals {
  # Qwen-Image 2.1 Turbo (Sep 2026): 8-step distill of Qwen-Image 2.1, with its
  # Qwen3-VL text encoder and VAE, as recommended on the unsloth model card. Replaces
  # Z-Image-Turbo at Q2_K / a Qwen3-4B IQ1_S encoder, quants picked for the old 4 GB
  # card. ~13 GiB in total.
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
}

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

resource "kubernetes_persistent_volume_claim_v1" "sd_outputs_pvc" {
  metadata {
    name      = "sd-outputs"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "stable_diffusion" {
  metadata {
    name      = "stable-diffusion"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
  }

  spec {
    replicas = 0

    selector {
      match_labels = {
        app = "stable-diffusion"
      }
    }

    template {
      metadata {
        labels = {
          app = "stable-diffusion"
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

        # Intel needs no custom runtime; the device plugin passes /dev/dri through.

        # sd-server cannot pull from Hugging Face itself, so fetch the three files
        # onto the models PVC if they are not there yet. Re-runs are no-ops.
        init_container {
          name    = "fetch-models"
          image   = "curlimages/curl:8.11.1"
          command = ["/bin/sh", "-ec"]
          args = [join("\n", concat(
            [for f in local.sd_files : "[ -s /models/${f.name} ] || { curl -fL --retry 3 -o /models/${f.name}.part https://huggingface.co/${f.src} && mv /models/${f.name}.part /models/${f.name}; }"],
            # sd-server scans its model roots for LoRAs / upscalers when these are
            # not given; point them at empty dirs so it doesn't walk the filesystem.
            ["mkdir -p /models/loras /models/upscalers"],
          ))]

          volume_mount {
            name       = "models"
            mount_path = "/models"
          }
        }

        container {
          name = "stable-diffusion"
          # Official Vulkan build of stable-diffusion.cpp; the old ECR image was a
          # CUDA build and fell back to CPU on the Arc card. master-vulkan is the only
          # Vulkan tag published, so it is pinned by digest.
          image   = "ghcr.io/leejet/stable-diffusion.cpp:master-vulkan@sha256:8a251df6868574f25504c96ed6dead7d5b445e140532515e839dce5fb2e981a9"
          command = ["/sd-server"]
          args = [
            "--listen-ip",
            "0.0.0.0",
            "--listen-port",
            "7860",
            "--diffusion-model",
            "/models/${local.sd_files.diffusion.name}",
            "--vae",
            "/models/${local.sd_files.vae.name}",
            "--llm",
            "/models/${local.sd_files.llm.name}",
            "--lora-model-dir",
            "/models/loras",
            "--hires-upscalers-dir",
            "/models/upscalers",
            # Turbo is distilled for 8 steps at CFG 1; these become the defaults for
            # requests that don't set their own.
            "--steps",
            "8",
            "--cfg-scale",
            "1.0",
            "--sampling-method",
            "euler",
            # The card is shared with llama-swap, which can hold ~19 GB on its own.
            # Keeping these weights in RAM and moving them over per stage avoids
            # running the card out of VRAM when both are busy.
            "--offload-to-cpu"
          ]

          resources {
            limits = {
              # --offload-to-cpu parks the ~13 GiB of weights in RAM.
              memory = "18Gi"
              # Without this the device plugin does not hand over /dev/dri at all.
              "gpu.intel.com/xe" = 1
            }
            requests = {
              memory             = "14Gi"
              "gpu.intel.com/xe" = 1
            }
          }

          volume_mount {
            name       = "models"
            mount_path = "/models"
          }

          volume_mount {
            name       = "outputs"
            mount_path = "/outputs"
          }

          port {
            container_port = 7860
          }
        }

        volume {
          name = "models"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.sd_models_pvc.metadata.0.name
          }
        }

        volume {
          name = "outputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.sd_outputs_pvc.metadata.0.name
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [spec.0.replicas]
  }
}

resource "kubernetes_service" "stable_diffusion" {
  metadata {
    name      = "stable-diffusion"
    namespace = kubernetes_namespace.ollama.id
    labels = {
      app = "stable-diffusion"
    }
  }

  spec {
    selector = {
      app = "stable-diffusion"
    }

    port {
      protocol    = "TCP"
      port        = 7860
      target_port = 7860
    }
  }
}
