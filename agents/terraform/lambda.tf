resource "aws_lambda_function" "bedrock_agent_action_group" {
  function_name    = "bedrock-agents-action-group"
  role             = aws_iam_role.lambda_execution_role.arn
  filename         = data.archive_file.lambda.output_path
  handler          = "lambda_handler.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.13"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_handler.py"
  output_path = "lambda.zip"
}
