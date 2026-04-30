resource "helm_release" "cilium" {
  name      = "cilium"
  namespace = "kube-system"

  version    = "1.17.7"
  chart      = "cilium-enterprise"
  repository = "https://helm.isovalent.com"

  values = [file("${path.module}/conf/cilium-enterprise-values.yaml")]
  wait   = false
  timeout = 1200
}
