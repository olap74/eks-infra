terraform {
  source = "../../../../..//modules/config-storage"
}

include {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env_vars.hcl"))
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  {
    env_name = local.env_vars.locals.env_name
    owner    = local.env_vars.locals.config-storage.owner
  }
)
