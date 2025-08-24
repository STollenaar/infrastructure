locals {
  ip_range = [
    "192.168.2.123",
    # "192.168.2.118",
  ]
}
module "jellyfin" {
  source = "./jellyfin"
  #   depends_on = [helm_release.cloudnativepg]

  hcp_client = {
    client_id     = data.aws_ssm_parameter.vault_client_id.value
    client_secret = data.aws_ssm_parameter.vault_client_secret.value
  }
}
