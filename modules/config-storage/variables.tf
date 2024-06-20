variable "admin_arns" {
  description = "admins that can access the kubeconfig bucket"
  type        = list(string)
  default     = []
}

variable "aws_profile" {
  description = "account"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "aws region"
}

variable "remote_state_bucket" {
  description = "Terraform remote state bucket, filled in by terragrunt"
}

variable "owner" {
  description = "team that owns this component"
  type        = string
  default     = null
}

variable "source_yaml" {
  description = "filename in kubeconfig bucket"
  type        = string
  default     = ""
}

variable "tags" {
  description = "custom tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "env_name" {
  description = "environment name"
}
