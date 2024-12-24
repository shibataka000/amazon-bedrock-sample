resource "aws_bedrockagent_agent" "main" {
  agent_name              = "my-first-agents"
  agent_resource_role_arn = aws_iam_role.execution_role.arn
  foundation_model        = var.foundation_model_id
  instruction             = "This is example for amazon bedrock agents."
}
