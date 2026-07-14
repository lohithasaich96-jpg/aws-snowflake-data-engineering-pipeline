variable "name_prefix" {
  description = "Prefix for bucket names"
  type        = string
}

variable "account_id" {
  description = "AWS account ID, appended to bucket names for global uniqueness"
  type        = string
}

variable "bucket_layers" {
  description = "Data-lake layers, one bucket each"
  type        = list(string)
  default     = ["raw", "processed", "curated", "logs"]
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS. Null uses SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "transition_ia_days" {
  description = "Days before transitioning objects to STANDARD_IA"
  type        = number
  default     = 30
}

variable "transition_glacier_days" {
  description = "Days before transitioning objects to GLACIER"
  type        = number
  default     = 90
}

variable "noncurrent_expiration_days" {
  description = "Days before deleting noncurrent object versions"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags applied to all buckets"
  type        = map(string)
  default     = {}
}
