resource "aws_lambda_function" "get_wheather_api" {
  function_name    = "get-weather-api"
  role             = aws_iam_role.get_wheather_api.arn
  filename         = data.archive_file.get_wheather_api.output_path
  handler          = "lambda_handler.lambda_handler"
  source_code_hash = data.archive_file.get_wheather_api.output_base64sha256
  runtime          = "python3.13"
}

data "archive_file" "get_wheather_api" {
  type        = "zip"
  source_file = "${path.module}/get_wheather_api/lambda_handler.py"
  output_path = "${path.module}/get_wheather_api/lambda.zip"
}

resource "aws_lambda_permission" "get_wheather_api" {
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.get_wheather_api.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = aws_bedrockagent_agent.wheather_forecaster.agent_arn
}
