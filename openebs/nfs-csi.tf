resource "helm_release" "csi_nfs" {
  name      = "csi-driver-nfs"
  namespace = kubernetes_namespace.openebs.id

  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  version    = "4.12.0"

  #   values = [templatefile("${path.module}/conf/nfs-csi-values.yaml", {
  #     nfs_path           = "/mnt/storage/kubernetes"
  #     storage_class_name = "nfs-csi-movies"
  #   })]
}

resource "kubernetes_storage_class" "nfs_other" {
  metadata {
    name = "nfs-csi-other"
  }

  storage_provisioner = "nfs.csi.k8s.io"
  volume_binding_mode = "Immediate"

  parameters = {
    server = "nas.home.spicedelver.me"
    share  = "/mnt/storage2/kubernetes"
    subDir = "$${pvc.metadata.namespace}/$${pvc.metadata.name}"
  }
  reclaim_policy = "Retain"
  mount_options = [
    "vers=4",
    "nolock"
  ]
}

resource "kubernetes_storage_class" "nfs_main" {
  metadata {
    name = "nfs-csi-main"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "nfs.csi.k8s.io"
  volume_binding_mode = "Immediate"

  parameters = {
    server = "nas.home.spicedelver.me"
    share  = "/mnt/main/kubernetes"
    subDir = "$${pvc.metadata.namespace}/$${pvc.metadata.name}"
  }
  reclaim_policy = "Retain"
  mount_options = [
    "vers=4",
    "nolock"
  ]
}

resource "kubernetes_storage_class" "nfs_main_no_retain" {
  metadata {
    name = "nfs-csi-main-no-retain"
  }

  storage_provisioner = "nfs.csi.k8s.io"
  volume_binding_mode = "Immediate"

  parameters = {
    server = "nas.home.spicedelver.me"
    share  = "/mnt/main/kubernetes"
    subDir = "$${pvc.metadata.namespace}/$${pvc.metadata.name}"
  }
  reclaim_policy = "Delete"
  mount_options = [
    "vers=4",
    "nolock"
  ]
}
