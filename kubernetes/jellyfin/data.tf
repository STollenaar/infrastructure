data "aws_ssm_parameter" "surfshark_openvpn_user" {
  name = "/surfshark/openvpn/user"
}

data "aws_ssm_parameter" "surfshark_openvpn_password" {
  name = "/surfshark/openvpn/password"
}

data "aws_ssm_parameter" "surfshark_wireguard_public_key" {
  name = "/surfshark/wireguard/public_key"
}

data "aws_ssm_parameter" "surfshark_wireguard_private_key" {
  name = "/surfshark/wireguard/private_key"
}
