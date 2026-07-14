output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "s3_buckets" {
  description = "Data-lake bucket names by layer"
  value       = module.s3.bucket_ids
}

output "ec2_public_ip" {
  description = "Public IP of the edge/scheduler EC2 host"
  value       = module.ec2.public_ip
}

output "snowflake_role_arn" {
  description = "Snowflake storage-integration role ARN"
  value       = module.iam.snowflake_role_arn
}

output "emr_cluster_id" {
  description = "EMR cluster ID (null when disabled)"
  value       = var.enable_emr ? module.emr[0].cluster_id : null
}

output "alerts_topic_arn" {
  description = "SNS topic ARN for CloudWatch alerts"
  value       = module.cloudwatch.alerts_topic_arn
}
