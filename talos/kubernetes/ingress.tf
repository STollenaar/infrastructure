resource "helm_release" "nginx-ingress" {
    depends_on = [kubernetes_manifest.metallb_ip_pool]
  name = "nginx-ingress"

  chart       = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  version     = "4.9.1"
  max_history = 50

  # Enable TLSv1.3
  values = [templatefile("${path.module}/conf/nginx-ingress-values.yaml", {
    cluster_ip = local.worker_nodes[0]
  })]
}