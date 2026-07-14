# EC2 instance profile + role, EMR service/instance roles, and the
# Snowflake storage-integration role used for external stages on S3.

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "ec2_s3" {
  name = "${var.name_prefix}-ec2-s3"
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = concat(var.data_bucket_arns, [for a in var.data_bucket_arns : "${a}/*"])
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# ---- EMR roles ----
data "aws_iam_policy_document" "emr_service_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "emr_service" {
  name               = "${var.name_prefix}-emr-service-role"
  assume_role_policy = data.aws_iam_policy_document.emr_service_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "emr_service" {
  role       = aws_iam_role.emr_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEMRServicePolicy_v2"
}

data "aws_iam_policy_document" "emr_ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "emr_ec2" {
  name               = "${var.name_prefix}-emr-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.emr_ec2_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "emr_ec2" {
  role       = aws_iam_role.emr_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "emr_ec2" {
  name = "${var.name_prefix}-emr-ec2-profile"
  role = aws_iam_role.emr_ec2.name
}

# ---- Snowflake storage integration role ----
# Trust policy is intentionally broad on create; after running
# DESC INTEGRATION in Snowflake, tighten the principal ARN + ExternalId.
data "aws_iam_policy_document" "snowflake_assume" {
  count = var.enable_snowflake_role ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.snowflake_iam_principal_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.snowflake_external_id]
    }
  }
}

resource "aws_iam_role" "snowflake" {
  count              = var.enable_snowflake_role ? 1 : 0
  name               = "${var.name_prefix}-snowflake-integration"
  assume_role_policy = data.aws_iam_policy_document.snowflake_assume[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy" "snowflake_s3" {
  count = var.enable_snowflake_role ? 1 : 0
  name  = "${var.name_prefix}-snowflake-s3"
  role  = aws_iam_role.snowflake[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket", "s3:GetBucketLocation"]
      Resource = concat(var.data_bucket_arns, [for a in var.data_bucket_arns : "${a}/*"])
    }]
  })
}
