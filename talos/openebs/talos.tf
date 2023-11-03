locals {
  cluster_name = "talos-proxmox-cluster"
  
  nodes = [
    {
        endpoint = "192.168.2.107"
        type = "controlplane"
    },
    {
        endpoint = "192.168.2.108"
        type = "worker"
    }
  ]
}

# resource "talos_machine_secrets" "this" {}

# data "talos_machine_configuration" "control_plane" {
#   cluster_name     = local.cluster_name
#   machine_type     = "controlplane"
#   cluster_endpoint = "https://192.168.2.107:6443"
#   machine_secrets  = talos_machine_secrets.this.machine_secrets
# }

# data "talos_client_configuration" "this" {
#   cluster_name         = local.cluster_name
#   client_configuration = talos_machine_secrets.this.client_configuration
#   nodes                = ["192.168.2.107"]
# }

# resource "talos_machine_configuration_apply" "control_plane_machine_apply" {
#   client_configuration        = talos_machine_secrets.this.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
#   node                        = "10.5.0.2"
#   config_patches = [
#     yamlencode({
#       op   = "add"
#       path = "/machine/install/extensions"
#       value = [
#         {
#           image = "ghcr.io/siderolabs/iscsi-tools:v0.1.4@sha256:58cbadb0a315d83e04b240de72c5ac584e9c63b690b2c4fcd629dd1566c3a7a1"
#         }
#       ]
#     }),
#     yamlencode(
#       {
#         op   = "add"
#         path = "/machine/kubelet/extraMounts"
#         value = [
#           {
#             destination = "/var/openebs/local"
#             type        = "bind"
#             source      = "/var/openebs/local"

#             options = [
#               "bind",
#               "rshared",
#               "rw"
#             ]
#           }
#         ]
#       }
#     )
#   ]
# }
