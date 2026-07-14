variable "name_prefix" {
  description = "Prefix for IAM resource names"
  type        = string
}

variable "data_bucket_arns" {
  description = "S3 bucket ARNs the roles are allowed to access"
  type        = list(string)
  default     = []
}

variable "enable_snowflake_role" {
  description = "Create the Snowflake storage-integration role"
  type        = bool
  default     = false
}

variable "snowflake_iam_principal_arn" {
  description = "STORAGE_AWS_IAM_USER_ARN from DESC INTEGRATION in Snowflake"
  type        = string
  default     = "arn:aws:iam::000000000000:root"
}

variable "snowflake_external_id" {
  description = "STORAGE_AWS_EXTERNAL_ID from DESC INTEGRATION in Snowflake"
  type        = string
  default     = "changeme"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
