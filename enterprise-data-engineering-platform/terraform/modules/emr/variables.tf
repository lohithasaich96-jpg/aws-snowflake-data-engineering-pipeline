variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "release_label" {
  type        = string
  description = "EMR release label"
  default     = "emr-7.2.0"
}

variable "applications" {
  type        = list(string)
  description = "EMR applications to install"
  default     = ["Spark", "Hadoop"]
}

variable "log_uri" {
  type        = string
  description = "S3 URI for EMR logs (e.g. s3://.../emr-logs/)"
}

variable "service_role_arn" {
  type        = string
  description = "EMR service role ARN"
}

variable "instance_profile_name" {
  type        = string
  description = "EMR EC2 instance profile name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet for the cluster"
}

variable "master_sg_id" {
  type        = string
  description = "Security group for the master node"
  default     = null
}

variable "slave_sg_id" {
  type        = string
  description = "Security group for core/task nodes"
  default     = null
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
  default     = null
}

variable "master_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Master node instance type"
}

variable "core_instance_type" {
  type        = string
  default     = "m5.xlarge"
  description = "Core node instance type"
}

variable "core_instance_count" {
  type        = number
  default     = 2
  description = "Number of core nodes"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources"
}
