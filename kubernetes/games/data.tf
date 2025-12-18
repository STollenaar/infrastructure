data "aws_ssm_parameter" "diplomacy_auth" {
  name            = "/diplomacy/password"
  with_decryption = true
}

data "aws_ssm_parameter" "factorio_username" {
  name = "/factorio/username"
}

data "aws_ssm_parameter" "factorio_token" {
  name = "/factorio/token"
}
