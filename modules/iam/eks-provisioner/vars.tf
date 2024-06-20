variable "aws_profile" {
}

variable "aws_region" {
}

variable "tags" {
  description = "Default tags for the module"
  type        = map(string)
}

variable "iam_group_devops" {
  description = "The name of the IAM Group to add to this role's trust policy"
  type        = string
  default     = ""
}

variable "iam_role_devops" {
  description = "The name of the IAM Role to add to this role's trust policy"
  type        = string
  default     = ""
}
