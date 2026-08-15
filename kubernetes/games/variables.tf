variable "vault_backend" {
  type = object({
    kind = string
    name = string
  })
}

variable "ecr_repositories" {
  type = object({
    diplomacy_repo            = string
    factorio_archipelago_repo = string
  })
}
