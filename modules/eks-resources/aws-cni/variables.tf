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

variable "environment" {
  description = "environment name"
  type        = string
}

variable "kubeconfig" {
    description = "Kubeconfig data"
    type        = string
}

variable "cni_version" {
  description = "CNI version"
  type        = string
  default     = "v1.16.0"
}
