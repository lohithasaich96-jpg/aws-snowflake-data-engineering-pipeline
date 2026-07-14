output "deploy_role_arn" {
  description = "Set this as the AWS_DEPLOY_ROLE_ARN GitHub Actions secret"
  value       = aws_iam_role.deploy.arn
}

output "state_bucket" {
  description = "S3 bucket holding Terraform remote state"
  value       = aws_s3_bucket.tfstate.id
}

output "lock_table" {
  description = "DynamoDB table used for state locking"
  value       = aws_dynamodb_table.tflock.id
}

output "backend_hcl" {
  description = "Paste-ready backend config for terraform/<env>/backend.hcl"
  value       = <<-EOT
    bucket         = "${aws_s3_bucket.tfstate.id}"
    key            = "platform/<env>/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.tflock.id}"
    encrypt        = true
  EOT
}
