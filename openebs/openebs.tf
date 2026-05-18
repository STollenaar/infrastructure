resource "kubernetes_namespace" "openebs" {
  metadata {
    name = "openebs"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "local_pv" {
  name      = "localpv"
  namespace = kubernetes_namespace.openebs.id

  repository = "https://openebs.github.io/dynamic-localpv-provisioner"
  chart      = "localpv-provisioner"
  version    = "4.4.0"

  values = [templatefile("${path.module}/conf/openebs-values.yaml", {})]
}
