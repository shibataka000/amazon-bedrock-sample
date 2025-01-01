resource "aws_bedrockagent_knowledge_base" "library" {
  name     = "library"
  role_arn = aws_iam_role.library.arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.library.model_arn
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.library.arn
      vector_index_name = opensearch_index.library.name
      field_mapping {
        vector_field   = local.aoss_vector_field_name
        text_field     = local.aoss_text_field_name
        metadata_field = local.aoss_metadata_field_name
      }
    }
  }
}

data "aws_bedrock_foundation_model" "library" {
  model_id = var.embedding_model_id
}

resource "aws_bedrockagent_data_source" "books" {
  name                 = "books"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.library.id
  data_deletion_policy = "RETAIN"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.books.arn
    }
  }
}
