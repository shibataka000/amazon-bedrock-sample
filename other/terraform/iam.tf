resource "aws_iam_role" "model_invocation_logging" {
  name               = "AmazonBedrockModelInvocationLogging"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.model_invocation_logging_assume_role_policy.json
}

resource "aws_iam_policy" "model_invocation_logging" {
  name_prefix = "AmazonBedrockModelInvocationLogging-"
  policy      = data.aws_iam_policy_document.model_invocation_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "model_invocation_logging" {
  role       = aws_iam_role.model_invocation_logging.name
  policy_arn = aws_iam_policy.model_invocation_logging.arn
}

data "aws_iam_policy_document" "model_invocation_logging_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

data "aws_iam_policy_document" "model_invocation_logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.model_invocation_logging.arn}:log-stream:aws/bedrock/modelinvocations"]
  }
}
