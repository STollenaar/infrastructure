locals {
  talos_version      = "1.14.5"
  kubernetes_version = "1.37.1"

  # Extensions baked into the gpu-worker's installer image. "xe" is the Xe2 KMD
  # (Battlemage); "mei" is required for discrete Arc cards to load their firmware;
  # "intel-ucode" is CPU microcode and unrelated to the GPU.
  gpu_extensions = [
    "xe",
    "mei",
    "intel-ucode",
  ]

  # Kernel args now ship in the Image Factory schematic (see conf/selinux-off.yaml).
  schematic_customization = yamldecode(file("${path.module}/conf/selinux-off.yaml")).customization

  # ghcr.io/siderolabs/installer is no longer published from Talos 1.14, so every
  # node installs from an Image Factory schematic.
  installer_images = {
    for v in var.nodes : v.name => "factory.talos.dev/metal-installer/${v.role == "gpu-worker" ? talos_image_factory_schematic.this.id : talos_image_factory_schematic.base.id}"
  }

  control_plane_nodes = { for v in var.nodes : v.name => v if v.role == "controlplane" }
  worker_nodes        = { for v in var.nodes : v.name => v if strcontains(v.role, "worker") }
}

data "talos_machine_configuration" "config" {
  for_each         = { for v in var.nodes : v.name => v }
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint

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
            endpoint = each.value.endpoint
        }),
        templatefile("${path.module}/conf/kubelet.yaml", {
          kubernetes_version = local.kubernetes_version
        }),
        templatefile("${path.module}/conf/custom-image.yaml", {
          image = "${local.installer_images[each.key]}:v${local.talos_version}"
        }),
        file("${path.module}/conf/cni-none.yaml"),
        file("${path.module}/conf/security-profile.yaml"),
      ],
      each.value.role == "controlplane" ? [
        file("${path.module}/conf/controlplane-scheduling.yaml")
      ] : [],
      each.value.role == "gpu-worker" ? [
        file("${path.module}/conf/intel-gpu.yaml"),
        file("${path.module}/conf/usbserial.yaml"),
      ] : [],
    )
  )
}

data "talos_client_configuration" "config" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoints            = [for k, v in local.control_plane_nodes : v.endpoint]
}

resource "talos_machine_secrets" "secrets" {}

resource "local_file" "talosconfig" {
  filename = "talosconfig"
  content  = data.talos_client_configuration.config.talos_config
}

# Intel Arc B-series (Battlemage, Xe2). Note there is deliberately no
# container-toolkit extension here: Intel ships no Talos extension that injects a
# userspace runtime into containers. The host supplies only the KMD
# and firmware; the Vulkan/Level-Zero/VA-API userspace lives in each image, and
# /dev/dri is handed out by the Intel GPU device plugin (see openebs/intel-gpu.tf).
data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = local.talos_version
  filters = {
    names = local.gpu_extensions
  }
}

# filters.names is a substring match, so "xe" also returns xen-guest-agent, which
# crash-loops on a non-Xen host ("Cannot identify hypervisor"). Keep only the
# extensions whose short name (after "siderolabs/") is exactly one we asked for.
locals {
  gpu_extension_names = [
    for e in data.talos_image_factory_extensions_versions.this.extensions_info : e.name
    if contains(local.gpu_extensions, element(split("/", e.name), length(split("/", e.name)) - 1))
  ]
}

# A check block only warns, which is how xen-guest-agent got through before. This
# one now guards the case where an exact name is missing from the factory.
check "gpu_extensions_resolved" {
  assert {
    condition = length(local.gpu_extension_names) == length(local.gpu_extensions)
    error_message = format(
      "expected %d GPU extension(s) %v, factory matched %d: %v",
      length(local.gpu_extensions),
      local.gpu_extensions,
      length(local.gpu_extension_names),
      local.gpu_extension_names,
    )
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = merge(local.schematic_customization, {
        # The Arc card is compute-only. Without this, xe takes over the VGA console
        # and the Proxmox console freezes after boot. It has to be a kernel arg:
        # udev autoloads xe before Talos applies KernelModuleConfig parameters.
        extraKernelArgs = concat(local.schematic_customization.extraKernelArgs, ["xe.probe_display=0"])
        systemExtensions = {
          officialExtensions = local.gpu_extension_names
        }
      })
    }
  )
}

# Schematic for the nodes without a GPU: no extensions, only the kernel args.
resource "talos_image_factory_schematic" "base" {
  schematic = yamlencode(
    {
      customization = local.schematic_customization
    }
  )
}

resource "talos_machine_configuration_apply" "node" {
  depends_on = [null_resource.upgrade_node, null_resource.upgrade_k8s]
  for_each   = data.talos_machine_configuration.config

  node = var.nodes[index(var.nodes.*.name, each.key)].endpoint

  apply_mode                  = "staged"
  machine_configuration_input = each.value.machine_configuration
  client_configuration        = talos_machine_secrets.secrets.client_configuration
}

resource "local_file" "machine_configs" {
  for_each = data.talos_machine_configuration.config

  filename = "${var.nodes[index(var.nodes.*.name, each.key)].name}.yaml"
  content  = each.value.machine_configuration
}

resource "null_resource" "upgrade_node" {
  for_each = { for v in var.nodes : v.name => v }

  triggers = {
    talos_version = local.talos_version
    schematic_id  = local.installer_images[each.key]
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
  depends_on = [null_resource.upgrade_node]
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
