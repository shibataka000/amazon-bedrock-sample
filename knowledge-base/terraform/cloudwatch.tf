resource "awscc_logs_delivery_source" "library" {
  name         = "library"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagent_knowledge_base.library.arn
  tags = [{
    key   = "Name"
    value = "library"
  }]
}

resource "awscc_logs_delivery_destination" "library" {
  name                     = "library"
  destination_resource_arn = aws_cloudwatch_log_group.library.arn
  output_format            = "json"
  tags = [{
    key   = "Name"
    value = "library"
  }]
}

resource "awscc_logs_delivery" "library" {
  delivery_source_name     = awscc_logs_delivery_source.library.name
  delivery_destination_arn = awscc_logs_delivery_destination.library.arn
  tags = [{
    key   = "Name"
    value = "library"
  }]
}

resource "aws_cloudwatch_log_group" "library" {
  name_prefix       = "library-"
  retention_in_days = 7
}
