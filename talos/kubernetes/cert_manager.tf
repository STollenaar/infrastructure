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
  version     = "v1.13.2"
  repository  = "https://charts.jetstack.io"
  namespace   = kubernetes_namespace.cert_manager.metadata.0.name
  wait        = false
  max_history = 50

  set {
    name  = "installCRDs"
    value = "true"
  }
}
