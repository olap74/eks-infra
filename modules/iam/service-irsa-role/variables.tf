variable "aws_profile" {
  description = "aws profile"
}

variable "aws_region" {
  description = "aws region"
}

variable "remote_state_bucket" {
  description = "Terraform remote state bucket, filled in by terragrunt"
}

variable "environment" {
  description = "Environment name (EKS cluster name)"
}

variable "cognito_id" {
    description = "Cognito user pool ID"
    type = string
}

variable "oidc_fully_qualified_subjects" {
    description = "OIDC fully qualified subjects"
    type        = list(string)
}

variable "roles" {
    description = "IaM Roles"
    type        = list(map(list(string)))
}

variable "env_metadata" {
    description = "Metadata (Resource tags)"
    type        = map(string)
}

variable "cluster_oidc_issuer_url" {
    description = "Cluster OIDC issuer URL"
    type        = string
}

variable "tags" {
  description = "additional resource tags"
  type        = map(string)
  default     = {}
}

variable "enable_overall_cognito" {
  description = "Include all Cognito user pools to policy or use the pool created for environment only"
  type        = bool
  default     = false
}

variable "oidc_subjects_with_wildcards" {
  description = "The OIDC subject using wildcards to be added to the role policy"
  type        = set(string)
  default     = []
}

variable "worker_role_id" {
  description = "The ARN of EKS worker"
  type        = string
  default     = ""
}
