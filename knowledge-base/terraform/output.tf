output "konowledge_base_id" {
  value = aws_bedrockagent_knowledge_base.library.id
}

output "data_source_id" {
  value = aws_bedrockagent_data_source.books.data_source_id
}

output "data_source_s3_bucket_name" {
  value = aws_s3_bucket.books.bucket
}
