locals {
  # Public Home Assistant endpoint, see kubernetes/homeassistant/homeassistant.tf
  homeassistant_url = "https://assistant.spicedelver.me"
}

# Alexa Smart Home skills can only be backed by Lambdas in us-east-1 (English NA),
# eu-west-1 or us-west-2, so this one does not live in the default ca-central-1.
provider "aws" {
  alias  = "alexa"
  region = "us-east-1"
}

resource "aws_lambda_function" "alexa_homeassistant" {
  provider = aws.alexa

  function_name = "homeassistant-alexa"
  description   = "Alexa Smart Home skill adapter for Home Assistant"
  role          = aws_iam_role.alexa_homeassistant.arn

  filename         = data.archive_file.alexa_homeassistant.output_path
  source_code_hash = data.archive_file.alexa_homeassistant.output_base64sha256

  runtime     = "python3.13"
  handler     = "lambda_function.lambda_handler"
  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      BASE_URL = local.homeassistant_url
    }
  }

  depends_on = [aws_cloudwatch_log_group.alexa_homeassistant]
}

resource "aws_lambda_permission" "alexa_homeassistant" {
  provider = aws.alexa

  statement_id       = "AllowExecutionFromAlexa"
  action             = "lambda:InvokeFunction"
  function_name      = aws_lambda_function.alexa_homeassistant.function_name
  principal          = "alexa-connectedhome.amazon.com"
  event_source_token = data.aws_ssm_parameter.alexa_skill_id.value
}

resource "aws_iam_role" "alexa_homeassistant" {
  name               = "homeassistant-alexa-lambda"
  assume_role_policy = data.aws_iam_policy_document.alexa_homeassistant_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alexa_homeassistant_logs" {
  role       = aws_iam_role.alexa_homeassistant.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "alexa_homeassistant" {
  provider = aws.alexa

  name              = "/aws/lambda/homeassistant-alexa"
  retention_in_days = 3
}
