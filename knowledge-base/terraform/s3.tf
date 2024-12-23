resource "aws_s3_bucket" "bedrock_knowledge_base_data_source" {
  bucket_prefix = "bedrock-knowledge-base-data-source-"
}

resource "aws_s3_object" "sample_csv" {
  bucket = aws_s3_bucket.bedrock_knowledge_base_data_source.id
  key    = "sample.csv"
  source = "sample.csv"
  etag   = filemd5("sample.csv")
}
