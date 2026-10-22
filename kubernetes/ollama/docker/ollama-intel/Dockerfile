# Ollama with a Vulkan driver, for Intel Arc.
#
# Ollama reaches Intel GPUs only through its Vulkan backend - there is no SYCL or
# Level Zero path upstream, only CUDA, ROCm, Metal and Vulkan. The official image
# does build that backend (llama-server-vulkan, --preset vulkan) but its runtime
# layer installs just `libvulkan1 libopenblas0`: the Vulkan *loader* and no ICD.
# A loader with no driver enumerates zero devices, so stock ollama/ollama sees no
# Intel GPU at all and silently falls back to CPU.
#
# mesa-vulkan-drivers supplies the missing piece, Mesa's Intel driver (ANV) plus
# its ICD manifest in /usr/share/vulkan/icd.d. Battlemage/Xe2 needs Mesa >= 24.3;
# noble-updates currently carries 25.2.8, and the official image is ubuntu:24.04,
# so the stock archive is new enough and no PPA is required.
#
# vulkan-tools is only for debugging - `vulkaninfo --summary` inside the running
# pod is the fastest way to confirm the card is visible.
ARG OLLAMA_VERSION=0.40.8
FROM ollama/ollama:${OLLAMA_VERSION}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        mesa-vulkan-drivers \
        vulkan-tools \
    && rm -rf /var/lib/apt/lists/*

# Inherited from the base image, repeated so a base change can't silently drop it.
ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]
