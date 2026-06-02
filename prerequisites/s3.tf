resource "aws_s3_bucket" "statebucket" {
  # provider = aws.thailand
  bucket = "${var.project_name}-tfstate-${var.environment}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "statesse" {
  # provider = aws.thailand
  bucket = aws_s3_bucket.statebucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "state_s3versioning" {
  # provider = aws.thailand
  bucket = aws_s3_bucket.statebucket.id
  versioning_configuration {
    status = "Enabled"
  }
}