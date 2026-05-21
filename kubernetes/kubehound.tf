locals {
  kubehound_host = "kubehound.home.spicedelver.me"
}

resource "kubernetes_namespace_v1" "kubehound" {
  metadata {
    name = "kubehound"
    labels = {
      app = "kubehound"
    }
  }
}

resource "kubernetes_config_map_v1" "kubehound_config" {
  metadata {
    name      = "kubehound-config"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  data = {
    "kubehound.yaml" = yamlencode({
      collector = {
        type = "live-k8s-api-collector"
        live = {
          rate_limit_per_second = 50
        }
      }
      storage = {
        retry       = 5
        retry_delay = "10s"
      }
      mongodb = {
        url                = "mongodb://mongodb.${kubernetes_namespace_v1.kubehound.id}.svc.cluster.local:27017"
        connection_timeout = "30s"
        wipe               = true
      }
      janusgraph = {
        url                 = "ws://kubegraph.${kubernetes_namespace_v1.kubehound.id}.svc.cluster.local:8182/gremlin"
        connection_timeout  = "30s"
        writer_worker_count = 10
      }
      builder = {
        vertex = {
          batch_size = 250
        }
        edge = {
          worker_pool_size            = 2
          batch_size                  = 250
          batch_size_cluster_impact   = 10
          large_cluster_optimizations = true
        }
      }
    })
  }
}

# ---------- RBAC for the scanner job ----------

resource "kubernetes_service_account_v1" "kubehound_scanner" {
  metadata {
    name      = "kubehound-scanner"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
}

resource "kubernetes_cluster_role_v1" "kubehound_scanner" {
  metadata {
    name = "kubehound-scanner"
  }
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    non_resource_urls = ["*"]
    verbs             = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "kubehound_scanner" {
  metadata {
    name = "kubehound-scanner"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.kubehound_scanner.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.kubehound_scanner.metadata.0.name
    namespace = kubernetes_namespace_v1.kubehound.id
  }
}

# ---------- MongoDB (graph metadata store) ----------
# StatefulSet on openebs-hostpath: WiredTiger needs POSIX file semantics that NFS
# can't provide. Pinned to hard-worker because the hostpath PV is node-local.

resource "kubernetes_stateful_set_v1" "kubehound_mongo" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace_v1.kubehound.id
    labels = {
      app = "mongodb"
    }
  }
  spec {
    service_name = "mongodb"
    replicas     = 1
    selector {
      match_labels = {
        app = "mongodb"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }
      spec {
        container {
          name  = "mongodb"
          image = "mongo:6.0.6"
          port {
            container_port = 27017
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              memory = "1Gi"
            }
          }
          readiness_probe {
            tcp_socket {
              port = 27017
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          volume_mount {
            name       = "data"
            mount_path = "/data/db"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "openebs-hostpath"
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "kubehound_mongo" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  spec {
    selector = {
      app = "mongodb"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

# ---------- JanusGraph (kubegraph) ----------

resource "kubernetes_persistent_volume_claim_v1" "kubehound_graph" {
  metadata {
    name      = "kubehound-graph"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "kubehound_graph" {
  metadata {
    name      = "kubegraph"
    namespace = kubernetes_namespace_v1.kubehound.id
    labels = {
      app = "kubegraph"
    }
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "kubegraph"
      }
    }
    template {
      metadata {
        labels = {
          app = "kubegraph"
        }
      }
      spec {
        container {
          name  = "kubegraph"
          image = "ghcr.io/datadog/kubehound-graph:v1.6.7"
          port {
            name           = "gremlin"
            container_port = 8182
          }
          port {
            name           = "metrics"
            container_port = 8099
          }
          resources {
            requests = {
              cpu    = "250m"
              memory = "1Gi"
            }
            limits = {
              memory = "6Gi"
            }
          }
          readiness_probe {
            tcp_socket {
              port = 8182
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            failure_threshold     = 12
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/janusgraph"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.kubehound_graph.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "kubehound_graph" {
  metadata {
    name      = "kubegraph"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  spec {
    selector = {
      app = "kubegraph"
    }
    port {
      name        = "gremlin"
      port        = 8182
      target_port = 8182
    }
    port {
      name        = "metrics"
      port        = 8099
      target_port = 8099
    }
  }
}

# ---------- UI (Jupyter graph-notebook visualizer) ----------

resource "kubernetes_secret_v1" "kubehound_ui" {
  metadata {
    name      = "kubehound-ui"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  data = {
    NOTEBOOK_PASSWORD = "admin"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "kubehound_ui" {
  metadata {
    name      = "kubehound-ui"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "kubehound_ui" {
  metadata {
    name      = "kubehound-ui"
    namespace = kubernetes_namespace_v1.kubehound.id
    labels = {
      app = "kubehound-ui"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "kubehound-ui"
      }
    }
    template {
      metadata {
        labels = {
          app = "kubehound-ui"
        }
      }
      spec {
        container {
          name  = "ui"
          image = "ghcr.io/datadog/kubehound-ui:v1.6.7"
          port {
            name           = "notebook"
            container_port = 8888
          }
          env {
            name = "NOTEBOOK_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.kubehound_ui.metadata.0.name
                key  = "NOTEBOOK_PASSWORD"
              }
            }
          }
          env {
            name  = "GRAPH_NOTEBOOK_SSL"
            value = "False"
          }
          env {
            name  = "GRAPH_NOTEBOOK_HOST"
            value = "kubegraph.${kubernetes_namespace_v1.kubehound.id}.svc.cluster.local"
          }
          env {
            name  = "GRAPH_NOTEBOOK_PORT"
            value = "8182"
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "512Mi"
            }
            limits = {
              memory = "1Gi"
            }
          }
          volume_mount {
            name       = "shared"
            mount_path = "/root/notebooks/shared"
          }
        }
        volume {
          name = "shared"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.kubehound_ui.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "kubehound_ui" {
  metadata {
    name      = "kubehound-ui"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  spec {
    selector = {
      app = "kubehound-ui"
    }
    port {
      port        = 8888
      target_port = 8888
    }
  }
}

resource "kubernetes_ingress_v1" "kubehound_ui" {
  metadata {
    name      = "kubehound-ui"
    namespace = kubernetes_namespace_v1.kubehound.id
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = local.kubehound_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.kubehound_ui.metadata.0.name
              port {
                number = 8888
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [local.kubehound_host]
      secret_name = "kubehound-ui-tls"
    }
  }
}

# ---------- Scanner CronJob ----------
# Runs `kubehound dump local /tmp/dump --ingest` weekly, pushing fresh data
# into mongo + kubegraph. Trigger ad-hoc with:
#   kubectl -n kubehound create job --from=cronjob/kubehound-scan kubehound-scan-manual
resource "kubernetes_cron_job_v1" "kubehound_scan" {
  metadata {
    name      = "kubehound-scan"
    namespace = kubernetes_namespace_v1.kubehound.id
  }
  spec {
    schedule                      = "0 3 * * 0"
    concurrency_policy            = "Forbid"
    successful_jobs_history_limit = 1
    failed_jobs_history_limit     = 3
    job_template {
      metadata {
        labels = {
          app = "kubehound-scan"
        }
      }
      spec {
        backoff_limit = 1
        template {
          metadata {
            labels = {
              app = "kubehound-scan"
            }
          }
          spec {
            service_account_name = kubernetes_service_account_v1.kubehound_scanner.metadata.0.name
            restart_policy       = "Never"
            security_context {
              fs_group = 65532
            }
            container {
              name  = "scan"
              image = "ghcr.io/datadog/kubehound-binary:v1.6.7"
              args  = ["dump", "local", "/tmp/dump", "--ingest", "-y"]
              env {
                name  = "KUBEHOUND_ENV"
                value = "prod"
              }
              env {
                name  = "KH_K8S_CLUSTER_NAME"
                value = "spicecluster"
              }
              env {
                name  = "KH_MONGODB_URL"
                value = "mongodb://mongodb.${kubernetes_namespace_v1.kubehound.id}.svc.cluster.local:27017"
              }
              env {
                name  = "KH_JANUSGRAPH_URL"
                value = "ws://kubegraph.${kubernetes_namespace_v1.kubehound.id}.svc.cluster.local:8182/gremlin"
              }
              resources {
                requests = {
                  cpu    = "200m"
                  memory = "512Mi"
                }
                limits = {
                  memory = "2Gi"
                }
              }
              volume_mount {
                name       = "config"
                mount_path = "/etc/kubehound"
                read_only  = true
              }
              volume_mount {
                name       = "dump"
                mount_path = "/tmp/dump"
              }
            }
            volume {
              name = "config"
              config_map {
                name = kubernetes_config_map_v1.kubehound_config.metadata.0.name
              }
            }
            volume {
              name = "dump"
              empty_dir {
                size_limit = "2Gi"
              }
            }
          }
        }
      }
    }
  }
}
