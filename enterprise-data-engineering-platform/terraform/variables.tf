variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name, used as the resource name prefix base"
  default     = "edp"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stage/prod)"
}

variable "owner" {
  type        = string
  description = "Owning team/person tag"
  default     = "data-engineering"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = false
  description = "Provision a NAT gateway (adds cost)"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for the edge/scheduler host"
}

variable "allowed_ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR allowed to SSH to the EC2 host"
}

variable "enable_emr" {
  type        = bool
  default     = false
  description = "Provision the EMR cluster (expensive; off by default)"
}

variable "emr_core_instance_count" {
  type        = number
  default     = 2
  description = "EMR core node count"
}

variable "enable_snowflake_role" {
  type        = bool
  default     = false
  description = "Create the Snowflake storage-integration IAM role"
}

variable "snowflake_iam_principal_arn" {
  type        = string
  default     = "arn:aws:iam::000000000000:root"
  description = "STORAGE_AWS_IAM_USER_ARN from Snowflake"
}

variable "snowflake_external_id" {
  type        = string
  default     = "changeme"
  description = "STORAGE_AWS_EXTERNAL_ID from Snowflake"
}

variable "alert_email" {
  type        = string
  default     = null
  description = "Email for CloudWatch alerts"
}
