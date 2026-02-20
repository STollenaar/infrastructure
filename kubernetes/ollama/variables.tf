variable "vault_backend" {
  type = object({
    kind = string
    name = string
  })
}
