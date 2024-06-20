terraform {
  source = "../../../..//modules/iam/eks-provisioner"
}

include {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = local.account_vars.locals
