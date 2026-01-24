resource "kubernetes_runtime_class_v1" "nvidia" {
  metadata {
    name = "nvidia"
  }

  handler = "nvidia"
}

resource "helm_release" "nvidia_device_plugin" {
  name       = "nvidia-device-plugin"
  namespace  = "kube-system"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  version    = "0.18.2"

  set = [
    {
      name  = "runtimeClassName"
      value = kubernetes_runtime_class_v1.nvidia.metadata.0.name
    },
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
    }
  ]
}
