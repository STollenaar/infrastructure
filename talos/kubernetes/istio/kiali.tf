resource "helm_release" "kiali" {
  name      = "kiali"
  namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name

  chart       = "kiali-operator"
  repository  = "https://kiali.org/helm-charts"
  version     = local.kiali_version
  max_history = 50
  wait        = true
  values = [templatefile("${path.module}/conf/kiali-values.yaml", {
    istio_namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
    kiali_version   = local.kiali_version
    # admin_password       = var.admin_password
    # base_domain          = var.base_domain,
    monitoring_namespace = var.monitoring_namespace
  })]
}

resource "null_resource" "uninstall_kiali" {
  triggers = {
    kubeconfig_file = var.kubeconfig_file
    namespace       = kubernetes_namespace_v1.istio_namespace.metadata.0.name
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    kubectl patch --kubeconfig=${self.triggers.kubeconfig_file} -n ${self.triggers.namespace} kialis.kiali.io kiali --type=json -p '[{"op":"remove","path":"/metadata/finalizers"}]' && \
    kubectl delete --kubeconfig=${self.triggers.kubeconfig_file} kiali --all --all-namespaces
    EOT
  }
}
