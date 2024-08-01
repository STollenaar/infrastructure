resource "helm_release" "csi_nfs" {
  name      = "csi-driver-nfs"
  namespace = kubernetes_namespace.openebs.metadata.0.name

  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  version    = "v4.8.0"

#   values = [templatefile("${path.module}/conf/nfs-csi-values.yaml", {
#     nfs_path           = "/mnt/storage/kubernetes"
#     storage_class_name = "nfs-csi-movies"
#   })]
}

resource "kubernetes_storage_class" "nfs_movies" {
  metadata {
    name = "nfs-csi-movies"
  }

  storage_provisioner = "nfs.csi.k8s.io"
  reclaim_policy      = "Retain"

  parameters = {
    server = "192.168.2.113"
    share  = "/mnt/storage/kubernetes"
    subDir = "$${pvc.metadata.namespace}/$${pvc.metadata.name}"
  }
  volume_binding_mode = "Immediate"
  mount_options = [
    "vers=4",
    "nolock"
  ]

}

resource "kubernetes_storage_class" "nfs_other" {
  metadata {
    name = "nfs-csi-other"
  }

  storage_provisioner = "nfs.csi.k8s.io"
  volume_binding_mode = "Immediate"

  parameters = {
    server = "192.168.2.113"
    share  = "/mnt/storage2/kubernetes"
    subDir = "$${pvc.metadata.namespace}/$${pvc.metadata.name}"
  }
  reclaim_policy = "Retain"
  mount_options = [
    "vers=4",
    "nolock"
  ]
}
