terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    awscc = {
      source = "hashicorp/awscc"
    }
    opensearch = {
      source = "opensearch-project/opensearch"
    }
  }
}
