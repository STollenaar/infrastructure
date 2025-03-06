resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name                          = "monitoring"
      "iam.amazonaws.com/permitted" = ".*"
    }
    labels = {
      "networking/namespace"               = "monitoring"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
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

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  depends_on = [null_resource.prometheus_operator_crd_install]

  chart       = "kube-prometheus-stack"
  repository  = "https://prometheus-community.github.io/helm-charts"
  version     = "62.7.0"
  namespace   = kubernetes_namespace.monitoring.metadata.0.name
  timeout     = 300
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

resource "helm_release" "nvidia_gpu_exporter" {
  name       = "nvidia-gpu-exporter"
  repository = "https://utkuozdemir.org/helm-charts"
  chart      = "nvidia-gpu-exporter"
  version    = "1.0.0" # Update to the latest version if needed
  namespace  = kubernetes_namespace.monitoring.metadata.0.name

  values = [<<EOF
image:
    tag: 1.3.1
    repository: 405934267152.dkr.ecr.ca-central-1.amazonaws.com/nvidia-exporter
imagePullSecrets:
- name: ${kubernetes_manifest.monitoring_external_secret.manifest.spec.target.name}
nodeSelector:
  nvidia.com/gpu.present: "true"
volumes: []
volumeMounts: []    
EOF
  ]
}

resource "kubernetes_manifest" "monitoring_vault_backend" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "vault-backend"
      namespace = kubernetes_namespace.monitoring.metadata.0.name
    }
    spec = {
      provider = {
        vault = {
          server  = "http://vault.${kubernetes_namespace.vault.metadata.0.name}.svc.cluster.local:8200"
          path    = "secret"
          version = "v2"
          auth = {
            kubernetes = {
              mountPath = "kubernetes"
              role      = "external-secrets"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "monitoring_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace.monitoring.metadata.0.name
    }
    spec = {
      secretStoreRef = {
        name = kubernetes_manifest.monitoring_vault_backend.manifest.metadata.name
        kind = kubernetes_manifest.monitoring_vault_backend.manifest.kind
      }
      target = {
        name = "regcred"
        template = {
          type          = "kubernetes.io/dockerconfigjson"
          mergePolicy   = "Replace"
          engineVersion = "v2"
        }
      }
      data = [
        {
          secretKey = ".dockerconfigjson"
          remoteRef = {
            key      = "ecr-auth"
            property = ".dockerconfigjson"
          }
        }
      ]
    }
  }
}
