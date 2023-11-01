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
    command = "kubectl --kubeconfig=$${HOME}/.kube/config/proxmox_kubeconfig annotate sc openebs-jiva-csi-default storageclass.kubernetes.io/is-default-class=true"
  }
}

resource "null_resource" "patch_openebs_cm" {
  triggers = {
    openebs_hash = helm_release.openebs_jiva.metadata.0.revision
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=$${HOME}/.kube/config/proxmox_kubeconfig --namespace ${kubernetes_namespace.openebs.metadata.0.name} replace -f ${path.module}/conf/iscsiadm.yaml"
  }
}

resource "null_resource" "patch_openebs" {
  depends_on = [null_resource.patch_openebs_cm]
  triggers = {
    openebs_hash = helm_release.openebs_jiva.metadata.0.revision
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=$${HOME}/.kube/config/proxmox_kubeconfig --namespace ${kubernetes_namespace.openebs.metadata.0.name} patch daemonset openebs-jiva-csi-node --type=json --patch '[{\"op\": \"add\", \"path\": \"/spec/template/spec/hostPID\", \"value\": true}]'"
  }
}


module "vault" {
  depends_on = [helm_release.openebs_jiva]
  source     = "./vault-k8s"

  vault_client = {
    client_id     = data.aws_ssm_parameter.vault_client_id.value
    client_secret = data.aws_ssm_parameter.vault_client_secret.value
  }
  aws_caller_identity = data.aws_caller_identity.current
}
