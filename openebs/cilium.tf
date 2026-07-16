resource "helm_release" "cilium" {
  name      = "cilium"
  namespace = "kube-system"

  version    = "1.17.7"
  chart      = "cilium-enterprise"
  repository = "https://helm.isovalent.com"

  values      = [file("${path.module}/conf/cilium-enterprise-values.yaml")]
  wait        = false
  timeout     = 1200
  max_history = 10
}

# Replaces the Ingress the cilium-enterprise chart used to render for the Hubble
# Timescape UI. The chart's Ingress used the service's named "ui" port; a
# VirtualServer upstream takes a number, and "ui" is 8080 on that service.
#
# The VirtualServer CRD is owned by the NGINX Ingress Controller in the kubernetes
# module, so that must be applied before this one plans cleanly.
resource "kubernetes_manifest" "hubble_timescape_ui_virtualserver" {
  depends_on = [helm_release.cilium]

  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "hubble-timescape-ui"
      namespace = "kube-system"
    }
    spec = {
      ingressClassName = "nginx"
      host             = "timescape.home.spicedelver.me"
      tls = {
        secret = "hubble-timescape-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "hubble-timescape-ui"
        service = "hubble-timescape"
        port    = 8080
      }]
      routes = [{
        path = "/"
        action = {
          pass = "hubble-timescape-ui"
        }
      }]
    }
  }
}
