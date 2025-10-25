locals {
  cluster_name = "talos-proxmox-cluster"
  nodes = [
    {
      name     = "talos-7zr-i5q"
      endpoint = "192.168.1.122"
      role     = "controlplane"
    },
    {
      name     = "talos-e5t-zk5"
      endpoint = "192.168.1.123"
      role     = "worker"
    },
    {
      name     = "talos-iso-cgi"
      endpoint = "192.168.1.124"
      role     = "gpu-worker"
    }
  ]
  nas_ip = "192.168.1.125"

  ip_range = [for n in local.nodes : n.endpoint if n.role != "controlplane"]

  controlplane_ip = [for n in local.nodes : n.endpoint if n.role == "controlplane"]

  cluster_endpoint = "https://${local.controlplane_ip[0]}"
}