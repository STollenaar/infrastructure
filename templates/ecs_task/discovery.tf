resource "aws_service_discovery_service" "discovery_service" {
  name = var.name

  dns_config {
    namespace_id = var.cluster_essentials.private_dns_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
