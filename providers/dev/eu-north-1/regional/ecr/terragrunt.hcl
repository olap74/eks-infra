terraform {
  source = "../../../../..//modules/ecr_repo"
}

include {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals
)
