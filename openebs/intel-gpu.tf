# Intel GPU enablement, replacing the NVIDIA GPU operator.
#
# The shapes of the two are not equivalent. The NVIDIA operator bundled a device
# plugin, gpu-feature-discovery and the container runtime classes, because the CUDA
# userspace has to be injected into every container. Intel has no such injection
# step: the xe KMD and firmware come from the Talos extensions (see
# talos/conf/intel-gpu.yaml) and each image carries its own Vulkan / Level Zero /
# VA-API userspace. So all that is needed here is a device plugin to advertise the
# GPU and hand /dev/dri to the pods that ask for it.
#
# The plugin advertises gpu.intel.com/xe on Xe2 hardware (Battlemage), not
# gpu.intel.com/i915 - workloads request that resource name. There is no
# runtimeClass any more; "nvidia" must be dropped wherever it was set.

resource "helm_release" "intel_device_plugin_operator" {
  name       = "intel-device-plugins-operator"
  namespace  = "kube-system"
  repository = "https://intel.github.io/helm-charts"
  chart      = "intel-device-plugins-operator"
  version    = "0.37.1"

  max_history = 5
}

resource "helm_release" "intel_gpu_plugin" {
  # The GPU chart only creates a GpuDevicePlugin custom resource, so the operator
  # that owns that CRD has to exist first.
  depends_on = [helm_release.intel_device_plugin_operator]

  name       = "intel-device-plugins-gpu"
  namespace  = "kube-system"
  repository = "https://intel.github.io/helm-charts"
  chart      = "intel-device-plugins-gpu"
  version    = "0.37.1"

  max_history = 5

  set = [
    {
      # The chart defaults to intel.feature.node.kubernetes.io/gpu, which depends on
      # its NodeFeatureRule being matched by NFD. Target the label Talos sets on the
      # gpu-worker instead so placement does not hinge on feature discovery.
      name  = "nodeSelector.intel\\.com/gpu\\.present"
      value = "true"
    },
    {
      # Exposes gpu.intel.com/monitoring, which a GPU metrics exporter must request
      # to read the card's counters.
      name  = "enableMonitoring"
      value = true
    },
    {
      # How many containers may hold the single card at once. This must not be 1:
      # under the NVIDIA operator nothing requested a gpu resource at all (pods just
      # set runtimeClass + NVIDIA_VISIBLE_DEVICES=all and shared freely), so jellyfin,
      # ollama and stable-diffusion were all on the GPU together. With the Intel
      # plugin the card is a countable resource, and 1 would let exactly one of them
      # schedule while the others sat Pending. 4 keeps today's behaviour with headroom.
      name  = "sharedDevNum"
      value = 4
    },
  ]
}
