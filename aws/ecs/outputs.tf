output "discord_bots_cluster" {
  value     = aws_ecs_cluster.discord_bots_cluster
  sensitive = true
}

output "discord_bots_capacity_providers" {
    value = [
        aws_ecs_capacity_provider.nano_provider
    ]
    sensitive = true
}

output "discord_bots_namespace" {
  value = aws_service_discovery_http_namespace.discord_bots_namespace
  sensitive = true
}
