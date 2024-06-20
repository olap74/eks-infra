variable "aws_profile" {
  description = "aws profile"
}

variable "aws_region" {
  description = "aws region"
}

variable "remote_state_bucket" {
  description = "Terraform remote state bucket, filled in by terragrunt"
}

variable "tags" {
  description = "additional resource tags"
  type        = map(string)
  default     = {}
}

variable "admin_arns" {
  description = "The ARN list of admins"
  type        = list(string)
  default     = []
}
