resource "helm_release" "nvidia_operator" {
  name       = "nvidia-gpu-operator"
  namespace  = "kube-system"
  repository = "https://helm.ngc.nvidia.com/nvidia"
  chart      = "gpu-operator"
  version    = "v26.3.3"

  set = [
    {
      name  = "driver.enabled"
      value = false
    },
    {
      name  = "toolkit.enabled"
      value = false
    },
    {
      name  = "hostPaths.driverInstallDir"
      value = "/usr/local"
    },
  ]
}
