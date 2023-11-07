variable "hcp_client" {
  type = object({
    client_id     = string
    client_secret = string
  })
}
