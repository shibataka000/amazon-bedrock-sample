# https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-components.html
# https://docs.aws.amazon.com/ja_jp/bedrock/latest/APIReference/API_CreateGuardrail.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_guardrail

resource "aws_bedrock_guardrail" "main" {
  name        = "example"
  description = "This is sample guardrail."

  blocked_input_messaging   = "The input was blocked."
  blocked_outputs_messaging = "The output was blocked."

  # Content filters
  # https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-content-filters.html

  content_policy_config {
    filters_config {
      type            = "SEXUAL"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
    filters_config {
      type            = "VIOLENCE"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
    filters_config {
      type            = "HATE"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
    filters_config {
      type            = "INSULTS"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
    filters_config {
      type            = "MISCONDUCT"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
    filters_config {
      type            = "PROMPT_ATTACK"
      input_strength  = "MEDIUM"
      output_strength = "NONE"
    }
  }

  # Denied topics
  # https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-denied-topics.html

  topic_policy_config {
    topics_config {
      name       = "investment_topic"
      type       = "DENY"
      definition = "Investment advice refers to inquiries, guidance, or recommendations regarding the management or allocation of funds or assets with the goal of generating returns ."
      examples   = ["Where should I invest my money ?"]
    }
  }

  # Word filters
  # https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-word-filters.html

  word_policy_config {
    managed_word_lists_config {
      type = "PROFANITY"
    }
    words_config {
      text = "HATE"
    }
    words_config {
      text = "死"
    }
  }

  # Sensitive information filters
  # https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-sensitive-filters.html

  sensitive_information_policy_config {
    pii_entities_config {
      action = "BLOCK"
      type   = "NAME"
    }

    regexes_config {
      action      = "BLOCK"
      description = "example regex"
      name        = "regex_example"
      pattern     = "^\\d{3}-\\d{2}-\\d{4}$"
    }
  }

  # Contextual grounding check

  contextual_grounding_policy_config {
    filters_config {
      type      = "GROUNDING"
      threshold = 0
    }
    filters_config {
      type      = "RELEVANCE"
      threshold = 0
    }
  }

  # Image content filters (not supported yet)
  # https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-mmfilter.html
}

resource "aws_bedrock_guardrail_version" "main" {
  guardrail_arn = aws_bedrock_guardrail.main.guardrail_arn
  description   = "v1"
  skip_destroy  = true
}
