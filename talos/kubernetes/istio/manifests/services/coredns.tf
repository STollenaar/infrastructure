resource "kubernetes_manifest" "allow_aws_coredns_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "core-dns-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "*.ca-central-1.compute.internal",
        "*.prometheus-operator-kube-p-coredns.kube-system.svc.cluster.local"
      ]
      ports = [
        {
          number   = 9153
          name     = "coredns"
          protocol = "GRPC"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "NONE"
    }
  }
}

resource "kubernetes_manifest" "allow_core_dns_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "core-dns"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "prometheus-operator-kube-p-coredns.kube-system.svc.cluster.local",
      ]
      ports = [
        {
          number   = 9153
          name     = "node"
          protocol = "HTTP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "allow_node_local_dns_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "node-local-dns"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "node-local-dns.kube-system.svc.cluster.local"
      ]
      ports = [
        {
          number   = 9100
          name     = "node"
          protocol = "TCP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "core_dns_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "core-dns"
      namespace = "kube-system"
    }
    spec = {
      hosts = [
        "*.ca-central-1.compute.internal",
        "*prometheus-operator-kube-p-coredns.kube-system.svc.cluster.local",
      ]
      http = [
        {
          match = [
            {
              port = 9153
            },
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-coredns.kube-system.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tls = [
        {
          match = [
            {
              port = 9153
              sniHosts = [
                "prometheus-operator-kube-p-coredns.kube-system.svc.cluster.local",
              ]
            }
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-coredns.kube-system.svc.cluster.local"
              }
            }
          ]
        }
      ]
      tcp = [
        {
          match = [
            {
              port = 9153
            },
          ]
          route = [
            {
              destination = {
                host = "prometheus-operator-kube-p-coredns.kube-system.svc.cluster.local"
                port = {
                  number = 9153
                }
              }
            }
          ]
        }
      ]
    }
  }
}
