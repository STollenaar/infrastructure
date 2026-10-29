resource "helm_release" "cilium" {
  name      = "cilium"
  namespace = "kube-system"

  # Community chart. Back from cilium-enterprise 1.17.7, which was only there for
  # Hubble Timescape. Kept on the same minor (1.17) for the switch: Cilium supports
  # moving one minor at a time, so 1.18 and then 1.19 are separate follow-up bumps.
  version    = "1.17.18"
  chart      = "cilium"
  repository = "https://helm.cilium.io/"

  values      = [file("${path.module}/conf/cilium-values.yaml")]
  wait        = false
  timeout     = 1200
  max_history = 10
}

resource "kubernetes_manifest" "hubble_ui_virtualserver" {
  depends_on = [helm_release.cilium]

  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "hubble-ui"
      namespace = "kube-system"
    }
    spec = {
      ingressClassName = "nginx"
      host             = "hubble.home.spicedelver.me"
      tls = {
        secret = "hubble-ui-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "hubble-ui"
        service = "hubble-ui"
        port    = 80
      }]
      routes = [{
        path = "/"
        action = {
          pass = "hubble-ui"
        }
      }]
    }
  }
}
