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
  version    = "0.17.3"

  set = [
    {
      name  = "runtimeClassName"
      value = kubernetes_runtime_class_v1.nvidia.metadata.0.name
    }
  ]
}
