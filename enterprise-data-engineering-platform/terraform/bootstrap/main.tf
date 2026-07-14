# One-time bootstrap for CI/CD. Uses LOCAL state (it provisions the very
# resources remote state depends on, so it can't use remote state itself).
#
# Creates:
#   - S3 bucket + DynamoDB table for Terraform remote state & locking
#   - GitHub Actions OIDC identity provider
#   - IAM role GitHub Actions assumes (scoped to your repo) to deploy
#
# Run once:  terraform -chdir=terraform/bootstrap init
#            terraform -chdir=terraform/bootstrap apply -var github_repo=OWNER/REPO
# Then copy the `deploy_role_arn` output into the AWS_DEPLOY_ROLE_ARN GitHub secret.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = "edp"
      Component = "bootstrap"
      ManagedBy = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id    = data.aws_caller_identity.current.account_id
  state_bucket  = "${var.project_name}-tfstate-${local.account_id}"
  lock_table    = "${var.project_name}-tflock"
  oidc_provider = "token.actions.githubusercontent.com"

  # Allow any branch/PR/environment of the repo unless caller narrows it.
  allowed_subjects = coalesce(var.allowed_subjects, ["repo:${var.github_repo}:*"])
}

# ---------- Remote state backend ----------
resource "aws_s3_bucket" "tfstate" {
  bucket = local.state_bucket
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tflock" {
  name         = local.lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# ---------- GitHub OIDC provider ----------
# Thumbprint is ignored by AWS for the GitHub OIDC endpoint, but the argument
# is still required by the provider; this is the well-known value.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://${local.oidc_provider}"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# ---------- Deploy role assumed by GitHub Actions ----------
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
    # Restrict which repo (and refs/environments) may assume the role.
    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider}:sub"
      values   = local.allowed_subjects
    }
  }
}

resource "aws_iam_role" "deploy" {
  name                 = "${var.project_name}-github-deploy"
  assume_role_policy   = data.aws_iam_policy_document.assume.json
  max_session_duration = 3600
}

# Broad by default so plan/apply work across the platform modules. Scope this
# down (least privilege) once the resource set stabilises.
resource "aws_iam_role_policy_attachment" "deploy" {
  role       = aws_iam_role.deploy.name
  policy_arn = var.deploy_policy_arn
}

# Allow the role to read/write remote state + acquire locks.
resource "aws_iam_role_policy" "state_access" {
  name = "tfstate-access"
  role = aws_iam_role.deploy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.tfstate.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.tfstate.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        Resource = aws_dynamodb_table.tflock.arn
      }
    ]
  })
}
