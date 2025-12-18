locals {
  worker_nodes = [for node in data.kubernetes_nodes.workers.nodes : node.status[0].addresses[index(node.status[0].addresses.*.type, "InternalIP")].address]
}

data "kubernetes_nodes" "workers" {
  metadata {
    labels = {
      "node-role.kubernetes.io/worker" = "worker"
    }
  }
}

resource "kubernetes_namespace" "metallb_system" {
  metadata {
    name = "metallb-system"

    labels = {
      "cmstate.spicedelver.me"             = "opt-out"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "metallb" {
  repository = "https://metallb.github.io/metallb"

  chart     = "metallb"
  name      = "metallb"
  version   = "0.15.3"
  namespace = kubernetes_namespace.metallb_system.id

  set = [
    {
      name  = "controller.resources.requests.memory"
      value = "55Mi"
    },
    {
      name  = "controller.resources.limits.memory"
      value = "120Mi"
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "10m"
    },
    {
      name  = "speaker.resources.requests.memory"
      value = "70Mi"
    },
    {
      name  = "speaker.resources.limits.memory"
      value = "200Mi"
    },
    {
      name  = "speaker.resources.requests.cpu"
      value = "15m"
    },
  ]
}

resource "kubernetes_manifest" "metallb_ip_pool" {
  depends_on = [helm_release.metallb]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.metallb_system.id
    }
    spec = {
      addresses = [for ip in var.ip_range : "${ip}/32"]
    }
  }
}

resource "kubernetes_manifest" "metallb_announcement" {
  depends_on = [helm_release.metallb]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.metallb_system.id
    }
  }
}
