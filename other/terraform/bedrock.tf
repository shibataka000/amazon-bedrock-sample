resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  logging_config {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.model_invocation_logging.name
      role_arn       = aws_iam_role.model_invocation_logging.arn
    }
  }
}
