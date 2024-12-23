resource "aws_iam_role" "amazon_bedrock_execution_role_for_knowledge_base" {
  name = "AmazonBedrockExecutionRoleForKnowledgeBase"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AmazonBedrockKnowledgeBaseTrustPolicy",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "bedrock.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : data.aws_caller_identity.current.account_id
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:bedrock:ap-northeast-1:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
          }
        }
      }
    ]
    }
  )
}

resource "aws_iam_policy" "amazon_bedrock_foundation_model_policy_for_knowledge_base" {
  name = "AmazonBedrockFoundationModelPolicyForKnowledgeBase"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "BedrockInvokeModelStatement",
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel"
        ],
        "Resource" : [
          data.aws_bedrock_foundation_model.embedding.model_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_bedrock_foundation_model_policy_for_knowledge_base" {
  role       = aws_iam_role.amazon_bedrock_execution_role_for_knowledge_base.name
  policy_arn = aws_iam_policy.amazon_bedrock_foundation_model_policy_for_knowledge_base.arn
}

resource "aws_iam_policy" "amazon_bedrock_oss_policy_for_knowledge_base" {
  name = "AmazonBedrockOSSPolicyForKnowledgeBase"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "OpenSearchServerlessAPIAccessAllStatement",
        "Effect" : "Allow",
        "Action" : [
          "aoss:APIAccessAll"
        ],
        "Resource" : [
          "arn:aws:aoss:ap-northeast-1:${data.aws_caller_identity.current.account_id}:collection/${aws_opensearchserverless_collection.bedrock_knowledge_base.id}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_bedrock_oss_policy_for_knowledge_base" {
  role       = aws_iam_role.amazon_bedrock_execution_role_for_knowledge_base.name
  policy_arn = aws_iam_policy.amazon_bedrock_oss_policy_for_knowledge_base.arn
}

resource "aws_iam_policy" "amazon_bedrock_s3_policy_for_knowledge_base" {
  name = "AmazonBedrockS3PolicyForKnowledgeBase"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3ListBucketStatement",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          aws_s3_bucket.bedrock_knowledge_base_data_source.arn
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : [
              data.aws_caller_identity.current.account_id
            ]
          }
        }
      },
      {
        "Sid" : "S3GetObjectStatement",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          aws_s3_object.sample_csv.arn,
          "${aws_s3_object.sample_csv.arn}.metadata.json",
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : [
              data.aws_caller_identity.current.account_id
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_bedrock_s3_policy_for_knowledge_base" {
  role       = aws_iam_role.amazon_bedrock_execution_role_for_knowledge_base.name
  policy_arn = aws_iam_policy.amazon_bedrock_s3_policy_for_knowledge_base.arn
}
