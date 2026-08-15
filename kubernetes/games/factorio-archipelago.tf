// A Factorio world bridged into an Archipelago multiworld hosted on
// archipelago.gg.
//
// The AP Factorio Client owns the Factorio process: it spawns the headless
// server, loads the generated AP mod, drives it over local RCON and relays items
// to and from the multiworld. That is why this cannot be the sqljames helm
// server in factorio.tf — that one is untouched and runs beside this, so only
// the node ports have to stay distinct (31497 vs 31498).

locals {
  archipelago = {
    // The Archipelago room this Factorio slot joins.
    server = "archipelago.gg"
    port   = 56785

    // The generated Factorio mod for our slot. archipelago.gg's slot_file
    // endpoint serves exactly this — note it is the *mod*, not the multidata.
    mod_urls = [
    ]

    factorio_port = 34197

    // Node ports must fall in Kubernetes' 30000-32767 range; 31497 is taken by
    // the vanilla helm server in factorio.tf.
    factorio_node_port = 31498

    image_tag = "0.6.7-2.0.28"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "factorio_archipelago_mods" {
  metadata {
    name      = "factorio-archipelago-mods"
    namespace = kubernetes_namespace_v1.factorio.id
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        "storage" = "2Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "factorio_archipelago_saves" {
  metadata {
    name      = "factorio-archipelago-saves"
    namespace = kubernetes_namespace_v1.factorio.id
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        "storage" = "10Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "factorio_archipelago" {
  metadata {
    name      = "factorio-archipelago"
    namespace = kubernetes_namespace_v1.factorio.id
    labels = {
      app = "factorio-archipelago"
    }
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "factorio-archipelago"
      }
    }
    template {
      metadata {
        labels = {
          app = "factorio-archipelago"
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_manifest.factorio_archipelago_external_secret.manifest.spec.target.name
        }

        // Populates the mods volume before the client starts: downloads anything
        // in FACTORIO_MOD_URLS that isn't already there, and writes the
        // mod-list.json that disables the Space Age DLC the AP mod conflicts with.
        init_container {
          name    = "fetch-mods"
          image   = "${var.ecr_repositories.factorio_archipelago_repo}:${local.archipelago.image_tag}"
          command = ["/usr/local/bin/download-mods.sh"]
          env {
            name  = "FACTORIO_MOD_URLS"
            value = join(" ", local.archipelago.mod_urls)
          }
          volume_mount {
            name       = "mods"
            mount_path = "/opt/factorio/mods"
          }
        }

        container {
          name  = "factorio-archipelago"
          image = "${var.ecr_repositories.factorio_archipelago_repo}:${local.archipelago.image_tag}"
          env {
            name  = "ARCHIPELAGO_SERVER"
            value = local.archipelago.server
          }
          env {
            name  = "ARCHIPELAGO_PORT"
            value = local.archipelago.port
          }
          env {
            name  = "FACTORIO_PORT"
            value = local.archipelago.factorio_port
          }
          port {
            container_port = local.archipelago.factorio_port
            name           = "factorio"
            protocol       = "UDP"
          }
          volume_mount {
            name       = "mods"
            mount_path = "/opt/factorio/mods"
          }
          volume_mount {
            name       = "saves"
            mount_path = "/opt/factorio/saves"
          }
          resources {
            requests = {
              cpu    = "500m"
              memory = "2Gi"
            }
            limits = {
              memory = "6Gi"
            }
          }
        }

        volume {
          name = "mods"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.factorio_archipelago_mods.metadata.0.name
          }
        }
        volume {
          name = "saves"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.factorio_archipelago_saves.metadata.0.name
          }
        }
      }
    }
  }
}

// Game traffic only. RCON stays inside the pod — the AP client talks to its own
// Factorio subprocess over localhost — so it is deliberately not exposed.
resource "kubernetes_service_v1" "factorio_archipelago" {
  metadata {
    name      = "factorio-archipelago"
    namespace = kubernetes_namespace_v1.factorio.id
    labels = {
      app = "factorio-archipelago"
    }
  }
  spec {
    type = "NodePort"
    selector = {
      app = "factorio-archipelago"
    }
    port {
      port        = local.archipelago.factorio_port
      target_port = "factorio"
      node_port   = local.archipelago.factorio_node_port
      protocol    = "UDP"
      name        = "factorio"
    }
  }
}

resource "kubernetes_manifest" "factorio_archipelago_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ecr-auth"
      namespace = kubernetes_namespace_v1.factorio.id
    }
    spec = {
      secretStoreRef = {
        name = var.vault_backend.name
        kind = var.vault_backend.kind
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
