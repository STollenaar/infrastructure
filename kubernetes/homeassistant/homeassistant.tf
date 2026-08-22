locals {
  # YAML config files in conf/, rendered into the homeassistant ConfigMap and
  # mounted individually into /config on top of the PVC.
  homeassistant_conf = fileset("${path.module}/conf", "*.yaml")

  # subPath mounts do not track ConfigMap updates, so changing a file in conf/
  # has to roll the pod. Hashing the contents into a pod annotation does that.
  homeassistant_conf_hash = sha256(join("", [
    for f in sort(tolist(local.homeassistant_conf)) : file("${path.module}/conf/${f}")
  ]))
}

resource "kubernetes_deployment_v1" "homeassistant" {
  metadata {
    name      = "homeassistant"
    namespace = kubernetes_namespace_v1.homeassistant.id
    labels = {
      app = "homeassistant"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "homeassistant"
      }
    }

    template {
      metadata {
        labels = {
          app = "homeassistant"
        }
        annotations = {
          "checksum/conf" = local.homeassistant_conf_hash
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/hostname"
                  operator = "In"
                  values   = ["talos-iso-cgi"]
                }
              }
            }
          }
        }

        container {
          name  = "homeassistant"
          image = "ghcr.io/home-assistant/home-assistant:2026.8.3"

          port {
            container_port = 8123
          }

          volume_mount {
            mount_path = "/config"
            name       = "config"
          }

          # Each conf/ file is layered onto the PVC as its own subPath mount so
          # the rest of /config (database, .storage, secrets.yaml) stays
          # writable. These files are read-only to Home Assistant.
          dynamic "volume_mount" {
            for_each = local.homeassistant_conf
            content {
              name       = "conf"
              mount_path = "/config/${volume_mount.value}"
              sub_path   = volume_mount.value
              read_only  = true
            }
          }

          # Zigbee dongle is provided by generic-device-plugin (devic.es/zigbee),
          # mounted at /dev/ttyUSB0 to match the ZHA integration config.
          # This replaces privileged + host_path passthrough.
          resources {
            limits = {
              "devic.es/zigbee" = 1
            }
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.ha_data.metadata[0].name
          }
        }

        volume {
          name = "conf"
          config_map {
            name = kubernetes_config_map_v1.homeassistant.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "homeassistant" {
  metadata {
    name      = "homeassistant"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  spec {
    selector = {
      app = "homeassistant"
    }

    port {
      port        = 8123
      target_port = 8123
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_persistent_volume_claim_v1" "ha_data" {
  metadata {
    name      = "homeassistant-config"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}


resource "kubernetes_manifest" "homeassistant_virtualserver" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "homeassistant"
      namespace = kubernetes_namespace_v1.homeassistant.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "assistant.home.spicedelver.me"
      tls = {
        secret = "assistant-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "homeassistant"
        service = kubernetes_service_v1.homeassistant.metadata.0.name
        port    = 8123
      }]
      routes = [{
        path = "/"
        action = {
          pass = "homeassistant"
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "homeassistant_virtualserver_public" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind       = "VirtualServer"
    metadata = {
      name      = "homeassistant-public"
      namespace = kubernetes_namespace_v1.homeassistant.id
    }
    spec = {
      ingressClassName = "nginx"
      host             = "assistant.spicedelver.me"
      externalDNS = {
        enable = true
      }

      tls = {
        secret = "assistant-public-tls"
        "cert-manager" = {
          "cluster-issuer" = "letsencrypt-prod"
        }
        redirect = {
          enable = true
        }
      }
      upstreams = [{
        name    = "homeassistant"
        service = kubernetes_service_v1.homeassistant.metadata.0.name
        port    = 8123
      }]
      routes = [{
        path = "/"
        action = {
          pass = "homeassistant"
        }
      }]
    }
  }
}

# Home Assistant's YAML config, sourced from conf/. Adding a .yaml file there
# is enough -- it gets picked up here and mounted into /config automatically.
resource "kubernetes_config_map_v1" "homeassistant" {
  metadata {
    name      = "homeassistant"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  data = {
    for f in local.homeassistant_conf : f => file("${path.module}/conf/${f}")
  }
}
