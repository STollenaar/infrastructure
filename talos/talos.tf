locals {
  talos_version      = "1.10.0"
  kubernetes_version = "1.33.0"

  cluster_name     = "talos-proxmox-cluster"
  cluster_endpoint = "https://192.168.2.122:6443"

  nodes = [
    {
      name     = "talos-7zr-i5q"
      endpoint = "192.168.2.122"
      role     = "controlplane"
    },
    {
      name     = "talos-e5t-zk5"
      endpoint = "192.168.2.118"
      role     = "worker"
    },
    {
      name     = "talos-iso-cgi"
      endpoint = "192.168.2.123"
      role     = "gpu-worker"
    }
  ]

  control_plane_nodes = { for v in local.nodes : v.name => v if v.role == "controlplane" }
  worker_nodes        = { for v in local.nodes : v.name => v if strcontains(v.role, "worker") }
}

data "talos_machine_configuration" "config" {
  for_each         = { for v in local.nodes : v.name => v }
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint

  machine_type    = each.value.role == "gpu-worker" ? "worker" : each.value.role
  machine_secrets = talos_machine_secrets.secrets.machine_secrets

  talos_version      = local.talos_version
  kubernetes_version = local.kubernetes_version
}

data "talos_client_configuration" "config" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoints            = [for k, v in local.control_plane_nodes : v.endpoint]
}

resource "talos_machine_secrets" "secrets" {}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = local.talos_version
  filters = {
    names = [
      "nvidia-open-gpu-kernel-modules-lts",
      "nvidia-container-toolkit-lts",
      "nvidia-fabricmanager-lts"
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

resource "talos_machine_configuration_apply" "node" {
  for_each = data.talos_machine_configuration.config

  node = local.nodes[index(local.nodes.*.name, each.key)].endpoint

  machine_configuration_input = each.value.machine_configuration
  client_configuration        = talos_machine_secrets.secrets.client_configuration

  config_patches = concat(
    [
      templatefile(
        "${path.module}/conf/install-hostname.yaml", {
          hostname = each.key
          endpoint = local.nodes[index(local.nodes.*.name, each.key)].endpoint
      }),
    ],
    local.nodes[index(local.nodes.*.name, each.key)].role == "controlplane" ? [
      file("${path.module}/conf/controlplane-scheduling.yaml")
    ] : [],
    local.nodes[index(local.nodes.*.name, each.key)].role == "gpu-worker" ? [
      templatefile("${path.module}/conf/custom-image.yaml", {
        image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.this.id}:v${local.talos_version}"
      }),
      file("${path.module}/conf/nvidia-kernel.yaml")
    ] : []
  )
}

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
