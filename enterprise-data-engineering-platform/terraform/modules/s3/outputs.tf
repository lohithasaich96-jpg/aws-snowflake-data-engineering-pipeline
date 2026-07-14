output "bucket_ids" {
  description = "Map of layer => bucket name"
  value       = { for k, b in aws_s3_bucket.this : k => b.id }
}

output "bucket_arns" {
  description = "Map of layer => bucket ARN"
  value       = { for k, b in aws_s3_bucket.this : k => b.arn }
}
