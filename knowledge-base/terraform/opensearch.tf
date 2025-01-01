resource "aws_opensearchserverless_collection" "library" {
  name = local.aoss_collection_name
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.library_encryption,
    aws_opensearchserverless_security_policy.library_network,
    aws_opensearchserverless_access_policy.library,
  ]
}

resource "aws_opensearchserverless_security_policy" "library_encryption" {
  name = local.aoss_collection_name
  type = "encryption"
  policy = jsonencode({
    "Rules" = [
      {
        "Resource" = [
          "collection/${local.aoss_collection_name}"
        ],
        "ResourceType" = "collection"
      }
    ],
    "AWSOwnedKey" = true
  })
}

resource "aws_opensearchserverless_security_policy" "library_network" {
  name = local.aoss_collection_name
  type = "network"
  policy = jsonencode([{
    "Rules" : [
      {
        "Resource" = [
          "collection/${local.aoss_collection_name}"
        ],
        "ResourceType" : "dashboard"
      },
      {
        "Resource" = [
          "collection/${local.aoss_collection_name}"
        ],
        "ResourceType" : "collection"
      }
    ],
    "AllowFromPublic" = true
  }])
}

resource "aws_opensearchserverless_access_policy" "library" {
  name = local.aoss_collection_name
  type = "data"
  policy = jsonencode([{
    "Rules" = [
      {
        "Resource" = [
          "collection/${local.aoss_collection_name}"
        ],
        "Permission" : [
          "aoss:DescribeCollectionItems",
          "aoss:CreateCollectionItems",
          "aoss:UpdateCollectionItems"
        ],
        "ResourceType" = "collection"
      },
      {
        "Resource" = [
          "index/${local.aoss_collection_name}/*"
        ],
        "Permission" = [
          "aoss:*",
          "aoss:UpdateIndex",
          "aoss:DescribeIndex",
          "aoss:ReadDocument",
          "aoss:WriteDocument",
          "aoss:CreateIndex"
        ],
        "ResourceType" = "index"
      }
    ],
    "Principal" = [
      aws_iam_role.library.arn,
      data.aws_caller_identity.current.arn,
    ],
  }])
}

resource "opensearch_index" "library" {
  name                           = "bedrock-knowledge-base-default-index"
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  force_destroy                  = true

  mappings = jsonencode(
    {
      "properties" : {
        "${local.aoss_vector_field_name}" : {
          "type" : "knn_vector",
          "dimension" : var.dimension,
          "method" : {
            "name" : "hnsw",
            "engine" : "faiss",
            "parameters" : {
              "m" : 16,
              "ef_construction" : 512
            },
            "space_type" : "l2"
          }
        },
        "${local.aoss_metadata_field_name}" : {
          "type" : "text",
          "index" : "false"
        },
        "${local.aoss_text_field_name}" : {
          "type" : "text",
          "index" : "true"
        }
      }
    }
  )

  lifecycle {
    ignore_changes = [
      mappings
    ]
  }

  depends_on = [
    aws_opensearchserverless_collection.library,
  ]
}
