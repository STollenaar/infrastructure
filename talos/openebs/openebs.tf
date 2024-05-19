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

resource "helm_release" "openebs_jiva" {
  name       = "openebs-jiva"
  version    = "3.5.1"
  namespace  = kubernetes_namespace.openebs.metadata.0.name
  repository = "https://openebs.github.io/jiva-operator"
  chart      = "jiva"

  set {
    name  = "defaultPolicy.replicas"
    value = 1
  }
}

resource "null_resource" "patch_openebs_sc" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_file} annotate sc openebs-jiva-csi-default storageclass.kubernetes.io/is-default-class=true"
  }
}

resource "null_resource" "patch_openebs_cm" {
  triggers = {
    openebs_hash = helm_release.openebs_jiva.metadata.0.revision
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_file} --namespace ${kubernetes_namespace.openebs.metadata.0.name} replace -f ${path.module}/conf/iscsiadm.yaml"
  }
}

resource "null_resource" "patch_openebs" {
  depends_on = [null_resource.patch_openebs_cm]
  triggers = {
    openebs_hash = helm_release.openebs_jiva.metadata.0.revision
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_file} --namespace ${kubernetes_namespace.openebs.metadata.0.name} patch daemonset openebs-jiva-csi-node --type=json --patch '[{\"op\": \"add\", \"path\": \"/spec/template/spec/hostPID\", \"value\": true}]'"
  }
}
