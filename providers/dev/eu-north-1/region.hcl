locals {
  aws_region = "eu-north-1"

  // ECR repos config
  repo_prefix = "dev-"
  services = [
    "deveks"
  ]

  admin_arns = [
    "arn:aws:iam::851725521654:root",
    "arn:aws:iam::851725521654:role/eks-provisioner",
    "arn:aws:iam::851725521654:user/terraform"
  ]
}
