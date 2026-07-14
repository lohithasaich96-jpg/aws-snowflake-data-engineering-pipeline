# Remote state in S3 with DynamoDB locking.
# Values are supplied per-environment via -backend-config, e.g.:
#   terraform init -backend-config=dev/backend.hcl
#
# Bootstrap the state bucket + lock table once (they cannot live in the
# state they secure) before running init against this backend.
terraform {
  backend "s3" {
    key     = "platform/terraform.tfstate"
    encrypt = true
    # bucket, region, dynamodb_table provided via -backend-config
  }
}
