variable "aws_region" {
  description = "aws region"
}

variable "aws_profile" {
  description = "aws profile"
}

variable "remote_state_bucket" {
  description = "Terraform remote state bucket, filled in by terragrunt"
}

variable "tags" {
  description = "Additional tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

variable "repo_prefix" {
  description = "String to prefix the repo, including any slashes that should be created."
  type        = string
  default     = ""
}

variable "services" {
  description = "Services that need to have ECR repositories created"
  type        = list(string)
  default     = []
}

