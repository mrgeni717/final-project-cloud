# S3 bucket that will hold every other module's terraform.tfstate file
resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.project_slug}-tfstate-${data.aws_caller_identity.current.account_id}"

  # Safety net: prevents "terraform destroy" from ever deleting this
  # bucket by accident, since it holds the state for everything else.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table used for state locking, so two "terraform apply" runs
# can never corrupt the same state file at the same time.
resource "aws_dynamodb_table" "tf_locks" {
  name         = "${var.project_slug}-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
