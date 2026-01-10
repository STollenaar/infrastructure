locals {
  registries = [
    "discordbots",
    "diplomacy",
    "renovate",
    "external-ip",
    "stable-diffusion"
  ]
}

moved {
  from = aws_ecr_repository.diplomacy
  to = aws_ecr_repository.registries["diplomacy"]
}
moved {
  from = aws_ecr_repository.discord_bots
  to = aws_ecr_repository.registries["discordbots"]
}
moved {
  from = aws_ecr_repository.renovate
  to = aws_ecr_repository.registries["renovate"]
}
moved {
  from = aws_ecr_repository.external_ip
  to = aws_ecr_repository.registries["external-ip"]
}

resource "aws_ecr_repository" "registries" {
  for_each = toset(local.registries)
  name     = each.key

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "remove_untagged" {
  for_each   = aws_ecr_repository.registries
  repository = each.key
  policy     = data.aws_ecr_lifecycle_policy_document.remove_untagged.json
}

data "aws_ecr_lifecycle_policy_document" "remove_untagged" {
  rule {
    priority    = 1
    description = "Remove Untagged images"

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_number = 1
      count_unit   = "days"
    }
    action {
      type = "expire"
    }
  }
}
