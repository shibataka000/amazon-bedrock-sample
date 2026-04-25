provider "aws" {}

provider "awscc" {}

provider "opensearch" {
  url         = aws_opensearchserverless_collection.library.collection_endpoint
  healthcheck = false
}
