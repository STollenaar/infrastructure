resource "kubernetes_secret_v1" "postgres_superuser" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.ollama.id
  }

  type = "kubernetes.io/basic-auth"

  data = {
    username = "postgres"
    password = "password"
  }
}

resource "kubernetes_manifest" "cnpg_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "postgres"
      namespace = kubernetes_namespace.ollama.id
    }
    spec = {
      instances             = 1
      imageName             = "ghcr.io/cloudnative-pg/postgresql:17"
      primaryUpdateStrategy = "unsupervised"

      superuserSecret = {
        name = kubernetes_secret_v1.postgres_superuser.metadata.0.name
      }
      enableSuperuserAccess = true

      # Local storage rather than nfs-csi-main: the NFS share squashes the
      # postgres uid (26) to the anonymous uid (0), so initdb can never own its
      # PGDATA directory. Local hostpath has no such squash, and avoids running
      # PostgreSQL on NFS (an anti-pattern). The PV is pinned to its node.
      storage = {
        storageClass = "openebs-hostpath"
        size         = "5Gi"
      }
    }
  }
}
