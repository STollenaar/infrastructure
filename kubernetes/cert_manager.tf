resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "cmstate.spicedelver.me" = "opt-out"
    }
  }
}

resource "helm_release" "cert_manager" {
  name        = "cert-manager"
  chart       = "cert-manager"
  version     = "v1.16.2"
  repository  = "https://charts.jetstack.io"
  namespace   = kubernetes_namespace.cert_manager.metadata.0.name
  wait        = false
  max_history = 50
}


resource "kubernetes_manifest" "vault_cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "vault-issuer"
    }
    spec = {
      vault = {
        path   = "pki_int/sign/cert-manager"
        server = "http://vault.vault.svc.cluster.local:8200"
        auth = {
          kubernetes = {
            role      = "cert-manager"
            mountPath = "/v1/auth/kubernetes"
            serviceAccountRef = {
              name = "cert-manager"
            }
          }
        }
      }
    }
  }
}
