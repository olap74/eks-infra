variable "aws_account" {
}

variable "aws_profile" {
}

# Set this to a default because specifying a region in the Route53 provider is misleading since Route53 is global.
variable "aws_region" {
  description = "AWS region to use for the Terraform provider. Route 53 is global so region does not apply to it."
}

variable "zone_name" {
}

variable "comment" {
  default = "Zone for EKS infra"
}

variable "tags" {
  type    = map(string)
  default = {}
}
