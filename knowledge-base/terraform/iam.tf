resource "aws_iam_role" "library" {
  name_prefix        = "library-"
  assume_role_policy = data.aws_iam_policy_document.library_assume_role_policy.json
}

resource "aws_iam_policy" "library" {
  name_prefix = "library-"
  policy      = data.aws_iam_policy_document.library_policy.json
}

resource "aws_iam_role_policy_attachment" "library" {
  role       = aws_iam_role.library.name
  policy_arn = aws_iam_policy.library.arn
}

data "aws_iam_policy_document" "library_assume_role_policy" {
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
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
    }
  }
}

data "aws_iam_policy_document" "library_policy" {
  statement {
    sid       = "BedrockInvokeModelStatement"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [data.aws_bedrock_foundation_model.library.model_arn]
  }
  statement {
    sid       = "OpenSearchServerlessAPIAccessAllStatement"
    effect    = "Allow"
    actions   = ["aoss:APIAccessAll"]
    resources = ["arn:aws:aoss:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:collection/${aws_opensearchserverless_collection.library.id}"]
  }
  statement {
    sid       = "S3ListBucketStatement"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.books.arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
  statement {
    sid       = "S3GetObjectStatement"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.books.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
