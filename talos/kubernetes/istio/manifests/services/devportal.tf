resource "kubernetes_manifest" "allow_devportal_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "devportal-services"
      namespace = "devportal2"
    }
    spec = {
      hosts = [
        "devportal.devportal2.svc.cluster.local",
      ]
      ports = [
        {
          number   = 8000
          name     = "http"
          protocol = "HTTP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "devportal_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "devportal"
      namespace = "devportal2"
    }
    spec = {
      hosts = [
        "devportal.devportal2.svc.cluster.local",
      ]
      http = [
        {
          match = [
            {
              port = 8000
            }
          ]
          route = [
            {
              destination = {
                host = "devportal.devportal2.svc.cluster.local"
              }
            }
          ]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "allow_devportal_fat_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "devportal-fat-services"
      namespace = "devportal2"
    }
    spec = {
      hosts = [
        "devportal-fat.devportal2.svc.cluster.local",
      ]
      ports = [
        {
          number   = 8000
          name     = "http"
          protocol = "HTTP"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "devportal_fat_virtual_service" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "devportal-fat"
      namespace = "devportal2"
    }
    spec = {
      hosts = [
        "devportal-fat.devportal2.svc.cluster.local",
      ]
      http = [
        {
          match = [
            {
              port = 8000
            }
          ]
          route = [
            {
              destination = {
                host = "devportal-fat.devportal2.svc.cluster.local"
              }
            }
          ]
        },
      ]
    }
  }
}

