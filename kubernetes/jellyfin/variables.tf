variable "vault_backend" {
  type = object({
    name = string
    kind = string
  })
}