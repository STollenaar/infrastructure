output "discord_bots_repo" {
  value     = aws_ecr_repository.registries["discordbots"]
  sensitive = true
}

output "diplomacy_repo" {
  value     = aws_ecr_repository.registries["diplomacy"]
  sensitive = true
}

output "external_ip_repo" {
  value = aws_ecr_repository.registries["external-ip"]
  sensitive = true
}

output "renovate_repo" {
  value = aws_ecr_repository.registries["renovate"]
  sensitive = true
}