resource "aws_bedrockagent_knowledge_base" "example" {
  name     = "example"
  role_arn = aws_iam_role.amazon_bedrock_execution_role_for_knowledge_base.arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.embedding.model_arn
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.bedrock_knowledge_base.arn
      vector_index_name = opensearch_index.bedrock_knowledge_base_default_index.name
      field_mapping {
        vector_field   = local.aoss_vector_field_name
        text_field     = local.aoss_text_field_name
        metadata_field = local.aoss_metadata_field_name
      }
    }
  }
}

resource "aws_bedrockagent_data_source" "example" {
  name                 = "example"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.example.id
  data_deletion_policy = "RETAIN"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.bedrock_knowledge_base_data_source.arn
    }
  }
}

data "aws_bedrock_foundation_model" "embedding" {
  model_id = var.embedding_model_id
}
