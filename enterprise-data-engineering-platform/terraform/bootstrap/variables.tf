variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for state backend + IAM"
}

variable "project_name" {
  type        = string
  default     = "edp"
  description = "Name prefix for bootstrap resources"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo in OWNER/REPO form (used to scope the OIDC trust)"
}

variable "allowed_subjects" {
  type        = list(string)
  default     = null
  description = <<-EOT
    OIDC 'sub' claims allowed to assume the deploy role. Defaults to any ref
    and environment of github_repo. Tighten to e.g.
    ["repo:OWNER/REPO:ref:refs/heads/main", "repo:OWNER/REPO:environment:prod"].
  EOT
}

variable "deploy_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
  description = "Managed policy attached to the deploy role. Scope down for least privilege."
}
