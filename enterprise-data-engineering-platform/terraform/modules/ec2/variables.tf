variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_id" {
  type        = string
  description = "VPC to launch into"
}

variable "subnet_id" {
  type        = string
  description = "Subnet to launch the instance in"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID; null uses latest Amazon Linux 2023"
  default     = null
}

variable "instance_profile_name" {
  type        = string
  description = "IAM instance profile name"
  default     = null
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH"
  default     = null
}

variable "user_data" {
  type        = string
  description = "Cloud-init user data"
  default     = null
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH"
  default     = "0.0.0.0/0"
}

variable "app_ports" {
  type        = list(number)
  description = "Extra TCP ports to open to the world"
  default     = []
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB"
  default     = 20
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default     = {}
}
