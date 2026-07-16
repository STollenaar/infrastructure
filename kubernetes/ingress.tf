# F5 NGINX Ingress Controller. Routing lives in VirtualServer / TransportServer /
# Policy resources next to each service, not in Ingress objects.
#
# This release replaces the community ingress-nginx chart that previously held the
# same release name. Swapping it needs an ordered bootstrap, because Helm installs
# a chart's crds/ directory on install but never on upgrade, and because
# kubernetes_manifest resolves a CRD against the live API at *plan* time:
#
#   tofu destroy -target=helm_release.nginx_ingress   # uninstall ingress-nginx, free the IP
#   tofu apply   -target=helm_release.nginx_ingress   # fresh install: NIC + its CRDs
#   tofu apply                                        # VirtualServers and everything else
#
# Letting Terraform upgrade this release in place instead would swap the chart
# without ever installing the CRDs, and every VirtualServer would fail to plan.
resource "helm_release" "nginx_ingress" {
  depends_on = [kubernetes_manifest.metallb_ip_pool, helm_release.cert_manager]
  name       = "nginx-ingress"
  namespace  = "default"

  chart       = "nginx-ingress"
  repository  = "https://helm.nginx.com/stable"
  version     = "2.6.4"
  max_history = 5

  values = [templatefile("${path.module}/conf/nginx-ingress-values.yaml", {
    load_balancer_main_ip = var.ip_range[0]
    # Raw UDP passthrough for the Space Engineers dedicated server game port.
    # The listener is declared here; games/spaceengineers.tf binds a
    # TransportServer to it by name.
    spaceengineers_game_port = 27016
  })]
}
