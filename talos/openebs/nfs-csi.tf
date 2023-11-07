resource "helm_release" "nfs_csi" {
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"

  name      = "nfs-subdir-external-provisioner"
  chart     = "nfs-subdir-external-provisioner"
  namespace = kubernetes_namespace.openebs.metadata.0.name

  values = [file("${path.module}/conf/nfs-csi-values.yaml")]
}
