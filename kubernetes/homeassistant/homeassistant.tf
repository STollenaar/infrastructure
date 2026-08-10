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
          image = "ghcr.io/home-assistant/home-assistant:2026.8.0"

          port {
            container_port = 8123
          }

          volume_mount {
            mount_path = "/config"
            name       = "config"
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

resource "kubernetes_config_map_v1" "homeassistant" {
  metadata {
    name      = "homeassistant"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }
  data = {
    "configuration.yaml" = <<EOF
        # Loads default set of integrations. Do not remove.
        default_config:

        http:
        use_x_forwarded_for: true
        trusted_proxies:
        - 127.0.0.1
        - 192.168.0.0/16 
        - 10.244.0.0/16

        # Load frontend themes from the themes folder
        frontend:
        themes: !include_dir_merge_named themes

        automation: !include automations.yaml
        script: !include scripts.yaml
        scene: !include scenes.yaml
    EOF
  }
}
