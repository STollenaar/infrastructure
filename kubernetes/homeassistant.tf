resource "kubernetes_namespace_v1" "homeassistant" {
  metadata {
    name = "homeassistant"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
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
          image = "ghcr.io/home-assistant/home-assistant:2025.12.4"

          port {
            container_port = 8123
          }

          volume_mount {
            mount_path = "/config"
            name       = "config"
          }
          volume_mount {
            name       = "zigbee"
            mount_path = "/dev/zigbee"
          }

          # recommended for Home Assistant
          security_context {
            privileged = true
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.ha_data.metadata[0].name
          }
        }

        volume {
          name = "zigbee"
          host_path {
            path = "/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_5890910df69aef11ac9db89061ce3355-if00-port0"
            type = "CharDevice"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "matter" {
  metadata {
    name      = "matter"
    namespace = kubernetes_namespace_v1.homeassistant.id
    labels = {
      app = "matter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "matter"
      }
    }

    template {
      metadata {
        labels = {
          app = "matter"
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
          name  = "matter"
          image = "ghcr.io/matter-js/python-matter-server:8.1.2"

          port {
            container_port = 5580
          }

          security_context {
            privileged = true
          }
          volume_mount {
            name       = "matter-data"
            mount_path = "/data"
          }
        }
        host_network = true

        volume {
          name = "matter-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.matter_data.metadata[0].name
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

resource "kubernetes_service_v1" "matter" {
  metadata {
    name      = "matter"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  spec {
    selector = {
      app = "matter"
    }

    port {
      port        = 5580
      target_port = 5580
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

resource "kubernetes_persistent_volume_claim_v1" "matter_data" {
  metadata {
    name      = "matter-data"
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

resource "kubernetes_ingress_v1" "homeassistant" {
  metadata {
    name      = "homeassistant"
    namespace = kubernetes_namespace_v1.homeassistant.id

    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "assistant.home.spicedelver.me"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.homeassistant.metadata.0.name
              port {
                number = 8123
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "assistant.home.spicedelver.me"
      ]
      secret_name = "assistant-tls"
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
