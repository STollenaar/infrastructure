locals {
  cluster_name = "talos-proxmox-cluster"
  nodes = [
    {
      name     = "talos-7zr-i5q"
      endpoint = "192.168.67.122"
      role     = "controlplane"
    },
    {
      name     = "talos-e5t-zk5"
      endpoint = "192.168.67.123"
      role     = "worker"
    },
    {
      name     = "talos-iso-cgi"
      endpoint = "192.168.67.124"
      role     = "gpu-worker"
    }
  ]
  nas_ip = "192.168.67.125"

  ip_range = [for n in local.nodes : n.endpoint if n.role != "controlplane"]

  controlplane_ip = [for n in local.nodes : n.endpoint if n.role == "controlplane"]
}