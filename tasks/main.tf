resource "aws_service_discovery_private_dns_namespace" "default_namespace" {
  name        = "default"
  description = "the default namespace"
  vpc         = var.vpc_id
}
