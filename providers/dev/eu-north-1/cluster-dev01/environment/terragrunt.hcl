terraform {
  source = "../../../../..//modules/environment"
}

include {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env_vars.hcl"))
}

dependencies {
  paths = ["../config-storage"]
}

dependency "root_dns_zone" {
  config_path = "../../../general/root-dns-zone"
  mock_outputs = {
    zone_name = "sre-practise.net"
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals.environment,
  {
    env_name          = local.env_vars.locals.env_name
    root_route53_zone = dependency.root_dns_zone.outputs.zone_name
  }
)
