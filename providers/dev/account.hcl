locals {
  aws_profile         = "own"
  aws_region          = "eu-north-1"
  aws_account         = "851725521654"
  remote_state_bucket = "terraform-eks-infra-dev"
  regions             = ["eu-north-1"]
  office_cidrs = [
    "88.156.139.89/32", # VPN Gateway
    "88.156.139.0/24"   # Local IP
  ]
  zone_name = "dev.sre-practise.net"
}
