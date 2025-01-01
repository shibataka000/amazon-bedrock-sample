resource "aws_cloudwatch_log_group" "model_invocation_logging" {
  name_prefix       = "amazon-bedrock-model-invocation-logs-"
  retention_in_days = 7
}
