locals {
  talos_version      = "1.11.0"
  kubernetes_version = "1.34.0"

  cluster_name     = "talos-proxmox-cluster"
  cluster_endpoint = "https://192.168.67.122:6443"

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

  config_patches = flatten(
    concat(
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
        templatefile("${path.module}/conf/nvidia-kernel.yaml", {
          image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.this.id}:v${local.talos_version}"
        }),
      ] : []
    )
  )
}

data "talos_client_configuration" "config" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoints            = [for k, v in local.control_plane_nodes : v.endpoint]
}

resource "talos_machine_secrets" "secrets" {}

resource "local_file" "talosconfig" {
  filename = "talosconfig"
  content  = data.talos_client_configuration.config.talos_config
}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = local.talos_version
  filters = {
    names = [
      "nonfree-kmod-nvidia-lts",
      "nvidia-container-toolkit-lts",
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
  depends_on = [null_resource.upgrade_node, null_resource.upgrade_k8s]
  for_each   = data.talos_machine_configuration.config

  node = local.nodes[index(local.nodes.*.name, each.key)].endpoint

  machine_configuration_input = each.value.machine_configuration
  client_configuration        = talos_machine_secrets.secrets.client_configuration
}

resource "null_resource" "upgrade_node" {
  for_each = { for v in local.nodes : v.name => v }

  triggers = {
    talos_version = local.talos_version
    schematic_id  = each.value.role == "gpu-worker" ? talos_image_factory_schematic.this.id : ""
  }

  provisioner "local-exec" {
    command = "flock $LOCK_FILE --command ${path.module}/conf/upgrade-node.sh"

    environment = {
      LOCK_FILE = "${path.module}/conf/.upgrade-node.lock"

      DESIRED_TALOS_TAG       = "v${self.triggers.talos_version}"
      DESIRED_TALOS_SCHEMATIC = self.triggers.schematic_id


      TALOS_CONFIG_PATH = local_file.talosconfig.filename
      TALOS_NODE        = each.value.endpoint
      TIMEOUT           = "10m"
    }
  }
}

resource "null_resource" "upgrade_k8s" {
    depends_on = [ null_resource.upgrade_node ]
  triggers = {
    k8s_version = local.kubernetes_version
  }

  provisioner "local-exec" {
    command = "flock $LOCK_FILE --command ${path.module}/conf/upgrade-k8s.sh"

    environment = {
      LOCK_FILE = "${path.module}/conf/.upgrade-k8s.lock"

      DESIRED_K8S_VERSION = "${self.triggers.k8s_version}"


      TALOS_CONFIG_PATH = local_file.talosconfig.filename
      TALOS_NODES       = join(",", [for k, v in local.control_plane_nodes : v.endpoint])
    }
  }
}
