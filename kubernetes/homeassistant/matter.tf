
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
