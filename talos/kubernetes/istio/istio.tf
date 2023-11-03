locals {
  istio_version = "1.19.3"
  kiali_version = "1.76.0"
}

resource "kubernetes_namespace_v1" "istio_namespace" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_labels" "kube_system_disable" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-system"
  }
  labels = {
    "istio-injection" = "disabled"
  }
}

resource "helm_release" "istio_base" {
  #   depends_on = [
  #     helm_release.cert_manager_istio_csr
  #   ]

  name        = "istio-base"
  chart       = "base"
  repository  = "https://istio-release.storage.googleapis.com/charts"
  version     = local.istio_version
  max_history = 50
  namespace   = kubernetes_namespace_v1.istio_namespace.metadata.0.name
  wait        = true
  values = [templatefile("${path.module}/conf/istio-base-values.yaml", {
    istio_namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
  })]
}

resource "helm_release" "istio_discovery" {
  depends_on = [
    helm_release.istio_base
  ]
  name = "istio-discovery"

  chart       = "istiod"
  repository  = "https://istio-release.storage.googleapis.com/charts"
  version     = local.istio_version
  max_history = 50
  wait        = true
  timeout     = 300
  namespace   = kubernetes_namespace_v1.istio_namespace.metadata.0.name

  values = [templatefile("${path.module}/conf/istio-istiod-values.yaml", {
    istio_namespace  = kubernetes_namespace_v1.istio_namespace.metadata.0.name
    jaeger_collector = "${kubernetes_service_v1.jeager_collector.metadata.0.name}.${kubernetes_namespace_v1.istio_namespace.metadata.0.name}.svc:9411",
    # cert_manager_namespace     = var.cert_manager_namespace
    # cert_manager_istio_csr_svc = helm_release.cert_manager_istio_csr.name
  })]
}

# resource "null_resource" "patch_istiod" {
#   depends_on = [
#     helm_release.istio_discovery
#   ]
#   triggers = {
#     kubeconfig_file = var.kubeconfig_file
#     # values_update   = md5(helm_release.istio_discovery.values[0])
#     namespace = kubernetes_namespace_v1.istio_namespace.metadata.0.name
#   }

#   provisioner "local-exec" {
#     when    = create
#     command = <<EOT
#         kubectl patch --kubeconfig=${self.triggers.kubeconfig_file} -n ${self.triggers.namespace} deployment istiod --type=json -p '${file("${path.module}/conf/istio-istiod-patch.json")}'
#      EOT
#   }
# }

resource "null_resource" "prometeus_monitors" {
  depends_on = [
    helm_release.istio_discovery
  ]
  triggers = {
    kubeconfig_file = var.kubeconfig_file
    istio_version   = local.istio_version
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT
        kubectl apply --kubeconfig=${self.triggers.kubeconfig_file} -f https://raw.githubusercontent.com/istio/istio/${self.triggers.istio_version}/samples/addons/extras/prometheus-operator.yaml
        kubectl apply --kubeconfig=${self.triggers.kubeconfig_file} -f ${path.module}/conf/istio-prometheus.yaml
     EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
        kubectl delete --kubeconfig=${self.triggers.kubeconfig_file} -f https://raw.githubusercontent.com/istio/istio/${self.triggers.istio_version}/samples/addons/extras/prometheus-operator.yaml
        kubectl delete --kubeconfig=${self.triggers.kubeconfig_file} -f ${path.module}/conf/istio-prometheus.yaml
    EOT
  }
}

resource "kubernetes_manifest" "telemetry_mesh_default" {
  manifest = {
    apiVersion = "telemetry.istio.io/v1alpha1"
    kind       = "Telemetry"
    metadata = {
      name      = "mesh-default"
      namespace = "istio-system"
    }
    spec = {
      accessLogging = [
        {
          providers = [
            {
              name = "envoy"
            }
          ]
        }
      ]
    }
  }
}


# resource "null_resource" "grafana_dashboard_import" {
#   provisioner "local-exec" {
#     command = "/bin/bash ${path.module}/conf/grafanaDashboardImport.bash"

#     environment = {
#       ISTIO_VERSION = local.istio_version
#       GRAFANA_HOST  = "https://grafana.${var.base_domain}"
#       GRAFANA_CRED  = "admin:${var.admin_password}"
#     }
#   }
# }

# module "service_manifests" {
#   depends_on = [
#     helm_release.istio_base,
#     helm_release.istio_discovery
#   ]
#   source = "./manifests/services"

#   kubeconfig_file      = var.kubeconfig_file
#   module_eks           = var.module_eks
#   admin_password       = var.admin_password
#   base_domain          = var.base_domain
#   monitoring_namespace = var.monitoring_namespace
#   istio_namespace      = kubernetes_namespace_v1.istio_namespace.metadata.0.name
# }

# module "authorization_manifests" {
#   depends_on = [
#     helm_release.istio_base,
#     helm_release.istio_discovery
#   ]
#   source = "./manifests/authorizations"

#   monitoring_namespace = var.monitoring_namespace
#   istio_namespace      = kubernetes_namespace_v1.istio_namespace.metadata.0.name
# }
