data "aws_ssm_parameter" "heating_agent_ha_token" {
  name = "/homeassistant/heating_agent_token"
}

data "aws_ssm_parameter" "heating_agent_api_key" {
  name = "/ollama/heating_agent_api_key"
}
