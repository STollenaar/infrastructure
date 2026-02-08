resource "kubernetes_config_map_v1" "mosquitto_config" {
  metadata {
    name      = "mosquitto-config"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  data = {
    "mosquitto.conf" = <<-EOF
      persistence true
      persistence_location /mosquitto/data
      log_dest stdout

      listener 1883
      allow_anonymous true
    EOF
  }
}

resource "kubernetes_deployment_v1" "mosquitto" {
  metadata {
    name      = "mosquitto"
    namespace = kubernetes_namespace_v1.homeassistant.id
    labels    = { app = "mosquitto" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "mosquitto" }
    }

    template {
      metadata {
        labels = { app = "mosquitto" }
      }

      spec {
        container {
          name  = "mosquitto"
          image = "eclipse-mosquitto:2"

          port {
            container_port = 1883
          }

          volume_mount {
            name       = "config"
            mount_path = "/mosquitto/config/mosquitto.conf"
            sub_path   = "mosquitto.conf"
          }

          volume_mount {
            name       = "data"
            mount_path = "/mosquitto/data"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.mosquitto_config.metadata[0].name
          }
        }

        volume {
          name = "data"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mosquitto" {
  metadata {
    name      = "mosquitto"
    namespace = kubernetes_namespace_v1.homeassistant.id
  }

  spec {
    selector = { app = "mosquitto" }

    port {
      name        = "mqtt"
      port        = 1883
      target_port = 1883
    }

    type = "ClusterIP"
  }
}
