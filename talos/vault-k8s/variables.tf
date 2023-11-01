variable "vault_client" {
  type = object({
    client_id     = string
    client_secret = string
  })
}

variable "aws_caller_identity" {}
