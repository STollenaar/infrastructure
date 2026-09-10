data "aws_ssm_parameter" "flight_aware_key" {
  name = "/flightaware/api_key"
}
