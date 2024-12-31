resource "aws_iam_role" "wheather_forecaster" {
  name_prefix        = "WheatherForecaster-"
  assume_role_policy = data.aws_iam_policy_document.wheather_forecaster_assume_role_policy.json
}

resource "aws_iam_policy" "wheather_forecaster" {
  name_prefix = "WheatherForecaster-"
  policy      = data.aws_iam_policy_document.wheather_forecaster_policy.json
}

resource "aws_iam_role_policy_attachment" "wheather_forecaster" {
  role       = aws_iam_role.wheather_forecaster.name
  policy_arn = aws_iam_policy.wheather_forecaster.arn
}

data "aws_iam_policy_document" "wheather_forecaster_assume_role_policy" {
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
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
    }
  }
}

data "aws_iam_policy_document" "wheather_forecaster_policy" {
  statement {
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [data.aws_bedrock_foundation_model.wheather_forecaster.model_arn]
  }
}

resource "aws_iam_role" "get_wheather_api" {
  name_prefix        = "GetWheatherAPI-"
  assume_role_policy = data.aws_iam_policy_document.get_wheather_api_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "get_wheather_api" {
  role       = aws_iam_role.get_wheather_api.name
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
}

data "aws_iam_policy_document" "get_wheather_api_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "aws_lambda_basic_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
