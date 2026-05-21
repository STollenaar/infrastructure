resource "kubernetes_daemonset" "generic_device_plugin" {
  metadata {
    name      = "generic-device-plugin"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "generic-device-plugin"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "generic-device-plugin"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "generic-device-plugin"
        }
      }

      spec {
        priority_class_name = "system-node-critical"

        toleration {
          operator = "Exists"
          effect   = "NoExecute"
        }

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }

        container {
          name  = "generic-device-plugin"
          image = "squat/generic-device-plugin"

          args = [
            "--device",
            <<-EOT
            name: tun
            groups:
              - count: 1000
                paths:
                  - path: /dev/net/tun
            EOT
            ,
            "--device",
            <<-EOT
            name: zigbee
            groups:
              - count: 1
                paths:
                  - path: /dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_5890910df69aef11ac9db89061ce3355-if00-port0
                    mountPath: /dev/ttyUSB0
            EOT
            ,
            "--device",
            <<-EOT
            name: rtlsdr
            groups:
              - count: 1
                usb:
                  - vendor: "0bda"
                    product: "2838"
            EOT
          ]

          resources {
            requests = {
              cpu    = "50m"
              memory = "10Mi"
            }

            limits = {
              cpu    = "50m"
              memory = "20Mi"
            }
          }

          port {
            container_port = 8080
            name           = "http"
          }

          security_context {
            privileged = true
          }

          volume_mount {
            name       = "device-plugin"
            mount_path = "/var/lib/kubelet/device-plugins"
          }

          volume_mount {
            name       = "dev"
            mount_path = "/dev"
          }
        }

        volume {
          name = "device-plugin"
          host_path {
            path = "/var/lib/kubelet/device-plugins"
          }
        }

        volume {
          name = "dev"
          host_path {
            path = "/dev"
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }
}
