resource "aws_ecr_repository" "discord_bots" {
  name = "discordbots"
}

resource "aws_ecr_repository" "diplomacy" {
  name = "diplomacy"
}

resource "aws_ecr_repository" "renovate" {
  name = "renovate"
}
