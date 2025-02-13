output "discord_bots_repo" {
  value     = aws_ecr_repository.discord_bots
  sensitive = true
}

output "diplomacy_repo" {
  value     = aws_ecr_repository.diplomacy
  sensitive = true
}
