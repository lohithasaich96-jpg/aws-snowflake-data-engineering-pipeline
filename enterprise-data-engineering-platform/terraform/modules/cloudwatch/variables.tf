variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "CloudWatch log retention in days"
}

variable "alert_email" {
  type        = string
  default     = null
  description = "Email address subscribed to the alerts SNS topic"
}

variable "ec2_instance_id" {
  type        = string
  default     = null
  description = "EC2 instance to monitor for CPU"
}

variable "cpu_threshold" {
  type        = number
  default     = 80
  description = "CPU % threshold for the alarm"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources"
}
