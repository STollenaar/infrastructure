resource "helm_release" "nfs_csi_movies" {
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"

  name      = "nfs-subdir-external-provisioner-movies"
  chart     = "nfs-subdir-external-provisioner"
  namespace = kubernetes_namespace.openebs.metadata.0.name

  values = [templatefile("${path.module}/conf/nfs-csi-values.yaml", {
    nfs_path           = "/mnt/storage/kubernetes"
    storage_class_name = "nfs-client-movies"
  })]
}

resource "helm_release" "nfs_csi_other" {
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"

  name      = "nfs-subdir-external-provisioner-other"
  chart     = "nfs-subdir-external-provisioner"
  namespace = kubernetes_namespace.openebs.metadata.0.name

  values = [templatefile("${path.module}/conf/nfs-csi-values.yaml", {
    nfs_path           = "/mnt/storage2/kubernetes"
    storage_class_name = "nfs-client-other"
  })]
}
