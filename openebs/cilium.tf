resource "helm_release" "cilium" {
  name      = "cilium"
  namespace = "kube-system"

  version    = "1.19.3"
  chart      = "cilium"
  repository = "https://helm.cilium.io/"

  values = [file("${path.module}/conf/cilium-values.yaml")]
}
