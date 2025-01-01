variable "embedding_model_id" {
  default     = "amazon.titan-embed-text-v1"
  description = "The foundation model ID for the library knowledge base."
  type        = string
}

variable "dimension" {
  default     = 1536
  description = "The dimension for the library knowledge base."
  type        = number
}
