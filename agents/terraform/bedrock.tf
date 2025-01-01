resource "aws_bedrockagent_agent" "wheather_forecaster" {
  agent_name              = "wheather-forecaster"
  agent_resource_role_arn = aws_iam_role.wheather_forecaster.arn
  foundation_model        = data.aws_bedrock_foundation_model.wheather_forecaster.id
  instruction             = "あなたは優秀な天気予報士です。あなたの役割は指定された場所の気温をGetWheaterAPIを使って取得して回答することです。"
}

data "aws_bedrock_foundation_model" "wheather_forecaster" {
  model_id = var.foundation_model_id
}

resource "aws_bedrockagent_agent_action_group" "get_wheather_api" {
  agent_id                   = aws_bedrockagent_agent.wheather_forecaster.id
  action_group_name          = "GetWeatherAPI"
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true
  action_group_executor {
    lambda = aws_lambda_function.get_wheather_api.arn
  }
  api_schema {
    payload = file("${path.module}/get_wheather_api/schema.yaml")
  }
}
