resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name                          = "monitoring"
      "iam.amazonaws.com/permitted" = ".*"
    }
    labels = {
      "networking/namespace" = "monitoring"
    }
    name = "monitoring"
  }
}


resource "null_resource" "prometheus_operator_crd_install" {
  triggers = {
    kubeconfig_filename = var.kubeconfig_file
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} alertmanagerconfigs.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} alertmanagers.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} podmonitors.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} probes.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} prometheusagents.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} prometheuses.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} prometheusrules.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} scrapeconfigs.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} servicemonitors.monitoring.coreos.com
        kubectl delete crd --kubeconfig=${self.triggers.kubeconfig_filename} thanosrulers.monitoring.coreos.com
      EOT
  }
}

# resource "helm_release" "prometheus_operator_crds" {
#   name       = "prometheus-crds"
#   depends_on = [null_resource.prometheus_operator_crd_install]

#   chart       = "crds"
#   repository  = "https://prometheus-community.github.io/helm-charts"
#   version     = "0.0.0"
#   namespace   = kubernetes_namespace.monitoring.metadata.0.name
#   wait        = true
#   max_history = 50
# }

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  depends_on = [null_resource.prometheus_operator_crd_install]

  chart       = "kube-prometheus-stack"
  repository  = "https://prometheus-community.github.io/helm-charts"
  version     = "52.1.0"
  namespace   = kubernetes_namespace.monitoring.metadata.0.name
  wait        = false
  max_history = 50

  values = [
    templatefile("${path.module}/conf/prometheus-operator-values.yaml",
      {
        # purpose = "prod",
        # grafana_role               = var.cluster_admin_iam.grafana.arn,
        # monitoring_namespace = kubernetes_namespace.monitoring.metadata.0.name,
    })
  ]
}

# resource "helm_release" "prometheus-adapter" {
#   name       = "prometheus-adapter"
#   depends_on = [helm_release.cert_manager]

#   chart         = "prometheus-adapter"
#   repository    = "https://prometheus-community.github.io/helm-charts"
#   version       = "4.1.1"
#   namespace     = kubernetes_namespace.monitoring.metadata.0.name
#   wait          = false
#   recreate_pods = true
#   max_history   = 50


#   values = [file("${path.module}/conf/prometheus-adapter-values.yaml")]
# }
