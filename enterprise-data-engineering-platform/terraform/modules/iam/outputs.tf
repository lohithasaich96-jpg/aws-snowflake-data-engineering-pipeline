output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_role_arn" {
  description = "EC2 role ARN"
  value       = aws_iam_role.ec2.arn
}

output "emr_service_role_arn" {
  description = "EMR service role ARN"
  value       = aws_iam_role.emr_service.arn
}

output "emr_ec2_instance_profile_name" {
  description = "EMR EC2 instance profile name"
  value       = aws_iam_instance_profile.emr_ec2.name
}

output "snowflake_role_arn" {
  description = "Snowflake storage-integration role ARN (null if disabled)"
  value       = var.enable_snowflake_role ? aws_iam_role.snowflake[0].arn : null
}
