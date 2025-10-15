# data "http" "myip" {
#   url = "http://ipv4.icanhazip.com"
# }

data "aws_ssm_parameter" "tailscale_client_id" {
  name = "/tailscale/client/id"
}

data "aws_ssm_parameter" "tailscale_client_secret" {
  name = "/tailscale/client/secret"
}

data "tailscale_devices" "homelab" {}