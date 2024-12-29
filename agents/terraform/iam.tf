resource "aws_iam_role" "bedrock_agent_execution_role" {
  name_prefix        = "AmazonBedrockExecutionRoleForAgents-"
  assume_role_policy = data.aws_iam_policy_document.bedrock_agent_execution_role_assume_role_policy.json
}

data "aws_iam_policy_document" "bedrock_agent_execution_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_iam_role_policy" "bedrock_agent_execution_role_policy" {
  role   = aws_iam_role.bedrock_agent_execution_role.id
  policy = data.aws_iam_policy_document.bedrock_agent_execution_role_policy.json
}

data "aws_iam_policy_document" "bedrock_agent_execution_role_policy" {
  statement {
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.foundation_model_id}",
    ]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "AWSLambdaExecutionRoleForBedrockAgentsActionGroup"
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_role_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_execution_role_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
