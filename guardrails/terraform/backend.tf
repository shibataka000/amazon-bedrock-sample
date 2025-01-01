terraform {
  backend "s3" {
    bucket       = "sbtk-tfstate"
    key          = "amazon-bedrock-sample/guardrails"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
