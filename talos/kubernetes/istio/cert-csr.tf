# resource "null_resource" "create_istio_root_ca" {
#   triggers = {
#     kubeconfig_file = var.kubeconfig_file
#   }
#   provisioner "local-exec" {
#     when    = create
#     command = <<EOT
#             kubectl apply --kubeconfig=${self.triggers.kubeconfig_file} -f ${path.module}/conf/istio-self-issuer.yaml
#     EOT
#   }
#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOT
#             kubectl delete --kubeconfig=${self.triggers.kubeconfig_file} -f ${path.module}/conf/istio-self-issuer.yaml
#     EOT
#   }
# }

# data "kubernetes_secret" "istio_root_ca" {
#   depends_on = [
#     null_resource.create_istio_root_ca
#   ]
#   metadata {
#     name      = "istio-ca"
#     namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
#   }
# }


# resource "kubernetes_secret" "istio_root_ca" {
#   metadata {
#     name      = "istio-root-ca"
#     namespace = var.cert_manager_namespace
#   }
#   data = nonsensitive(merge(
#     data.kubernetes_secret.istio_root_ca.data,
#     {
#       "ca.pem" = lookup(data.kubernetes_secret.istio_root_ca.data, "tls.crt")
#     }
#     )
#   )

# }

# resource "helm_release" "cert_manager_istio_csr" {
#   depends_on = [
#     kubernetes_secret.istio_root_ca
#   ]
#   name        = "cert-manager-istio-csr"
#   chart       = "cert-manager-istio-csr"
#   repository  = "https://charts.jetstack.io"
#   version     = "v0.6.0"
#   max_history = 50
#   namespace   = var.cert_manager_namespace
#   wait        = true
#   values = [templatefile("${path.module}/conf/cert-manager-istio-csr-values.yaml", {
#     istio_namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
#   })]
# }
