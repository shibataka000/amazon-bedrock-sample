resource "aws_bedrockagent_agent" "main" {
  agent_name              = "my-first-agents"
  agent_resource_role_arn = aws_iam_role.bedrock_agent_execution_role.arn
  foundation_model        = var.foundation_model_id
  instruction             = "This is example for amazon bedrock agents."
}

resource "aws_bedrockagent_agent_action_group" "lambda" {
  action_group_name          = "lambda"
  agent_id                   = aws_bedrockagent_agent.main.id
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true
  action_group_executor {
    lambda = aws_lambda_function.bedrock_agent_action_group.arn
  }
  api_schema {
    payload = file("schema.yaml")
  }
}
