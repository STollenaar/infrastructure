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
  version     = "92.11.0"
  namespace   = kubernetes_namespace.monitoring.id
  timeout     = 300
  wait        = false
  max_history = 5

  values = [
    templatefile("${path.module}/conf/prometheus-operator-values.yaml",
    {})
  ]
}

# Replaces the Ingress the kube-prometheus-stack chart used to render
# (grafana.ingress).
resource "kubernetes_manifest" "grafana_virtualserver" {
  depends_on = [helm_release.prometheus_operator]

  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "grafana"
      namespace = kubernetes_namespace.monitoring.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "grafana.home.spicedelver.me"
      tls = {
        secret = "grafana-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "grafana"
        service = "${helm_release.prometheus_operator.name}-grafana"
        port    = 80
      }]
      routes = [{
        path = "/"
        action = {
          pass = "grafana"
        }
      }]
    }
  }
}

# Disabled rather than deleted, so it is one line away from coming back if the Arc
# card gets rolled back to the GTX 980. It scrapes nvidia-smi, so it can only fail
# against an Intel GPU.
#
# The Intel replacement is XPU Manager (intel/xpumanager on DockerHub), which does
# list Arc B-series as supported hardware and ships a Prometheus exporter. It is NOT
# wired up here because Intel publishes no Helm chart for it and no Kubernetes
# manifests in the repo, so the exporter's port, metrics path and image tag are all
# unverified - guessing them would just produce a DaemonSet that silently never
# scrapes. Deploying it also wants the gpu.intel.com/monitoring resource that
# openebs/intel-gpu.tf now enables.
#
# Still pointing at the old exporter and worth revisiting alongside it:
#   - kubernetes/conf/prometheus-operator-values.yaml  (nvidia-gpu-exporter scrape job)
#   - kubernetes/conf/grafana/nvidia-gpu-exporter.json (dashboard)
resource "helm_release" "nvidia_gpu_exporter" {
  count = 0

  name       = "nvidia-gpu-exporter"
  repository = "https://utkuozdemir.org/helm-charts"
  chart      = "nvidia-gpu-exporter"
  version    = "1.0.2" # Update to the latest version if needed
  namespace  = kubernetes_namespace.monitoring.id

  max_history = 5

  values = [<<EOF
image:
    tag: 1.4.1
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

resource "kubernetes_manifest" "monitoring_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace.monitoring.id
    }
    spec = {
      secretStoreRef = {
        name = kubernetes_manifest.vault_backend.manifest.metadata.name
        kind = kubernetes_manifest.vault_backend.manifest.kind
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

resource "kubernetes_config_map_v1" "nvidia_gpu_exporter_dashboard" {
  metadata {
    name      = "nvidia-gpu-exporter-dashboard"
    namespace = kubernetes_namespace.monitoring.id
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "nvidia-gpu-exporter.json" = file("${path.module}/conf/grafana/nvidia-gpu-exporter.json")
  }
}

resource "helm_release" "loki" {
  name      = "loki"
  namespace = kubernetes_namespace.monitoring.id

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "7.5.0"

  max_history = 5

  values = [templatefile("${path.module}/conf/loki-values.yaml", {})]
}

# Ships container logs from every node into Loki. Without this Loki stays empty.
resource "helm_release" "alloy" {
  name      = "alloy"
  namespace = kubernetes_namespace.monitoring.id

  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "1.14.2"

  depends_on = [helm_release.loki]

  max_history = 5

  values = [templatefile("${path.module}/conf/alloy-values.yaml", {})]
}
