data "archive_file" "alexa_homeassistant" {
  type        = "zip"
  source_dir  = "${path.module}/homeassistantalexa"
  output_path = "${path.module}/.terraform/homeassistantalexa.zip"
}

# Skill ID of the Alexa Smart Home skill (amzn1.ask.skill.xxxx), only known
# after the skill is created in the Alexa developer console.
data "aws_ssm_parameter" "alexa_skill_id" {
  name = "/alexa/homeassistant/skill_id"
}

data "aws_iam_policy_document" "alexa_homeassistant_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
