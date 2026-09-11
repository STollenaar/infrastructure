data "aws_ssm_parameter" "flight_radar_key" {
  name = "/flightradar24/api_key"
}

data "aws_ssm_parameter" "flight_aware_key" {
  name = "/flightaware/api_key"
}

data "aws_ssm_parameter" "flight_aware_feeder_id" {
  name = "/flightaware/feeder_id"
}

data "aws_ssm_parameter" "planes_location" {
  name = "/planes/location"
}

data "aws_ssm_parameter" "adsb_win" {
  name = "/adsbwin/uuid"
}

data "aws_ssm_parameter" "adsb_exchange" {
  name = "/adsbexchange/uuid"
}
