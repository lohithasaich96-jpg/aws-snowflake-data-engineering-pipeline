# Data-lake style buckets: raw / processed / curated, plus a logs bucket.

locals {
  buckets = toset(var.bucket_layers)
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = "${var.name_prefix}-${each.key}-${var.account_id}"
  tags     = merge(var.tags, { Layer = each.key })
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each                = aws_s3_bucket.this
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id

  rule {
    id     = "transition-and-expire"
    status = "Enabled"

    filter {}

    transition {
      days          = var.transition_ia_days
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = var.transition_glacier_days
      storage_class = "GLACIER"
    }
    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_expiration_days
    }
  }
}
