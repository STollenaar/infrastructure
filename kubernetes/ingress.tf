resource "helm_release" "nginx-ingress" {
  depends_on = [kubernetes_manifest.metallb_ip_pool]
  name       = "nginx-ingress"

  chart       = "ingress-nginx"
  repository  = "https://kubernetes.github.io/ingress-nginx"
  version     = "4.13.3"
  max_history = 50

  # Enable TLSv1.3
  values = [templatefile("${path.module}/conf/nginx-ingress-values.yaml", {
    load_balancer_main_ip = local.ip_range[0]
  })]
}
# resource "kubernetes_ingress_v1" "ingress" {
#   metadata {
#     name      = "default-ingress"
#     namespace = "default"
#     annotations = {
#       "kubernetes.io/ingress.class"                = "nginx"
#       "nginx.ingress.kubernetes.io/server-snippet" = <<EOT
#       location ~* "^/" {
#           deny all;
#           return 444;
#         }
#       EOT
#       "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
#     }
#   }
#   spec {
#     tls {
#       hosts       = ["*.spicedelver.me"]
#       secret_name = "nginx-ingress-tls"
#     }
#     default_backend {
#       service {
#         name = "nginx-ingress-ingress-nginx-controller"
#         port {
#           number = 80
#         }
#       }
#     }
#   }
# }
