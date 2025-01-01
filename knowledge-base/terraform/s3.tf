resource "aws_s3_bucket" "books" {
  bucket_prefix = "books-"
  force_destroy = true
}
