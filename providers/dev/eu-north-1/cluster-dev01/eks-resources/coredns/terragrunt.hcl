terraform {
  source = "../../../../../..//modules/eks-resources/coredns"
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
  paths = ["../../eks-node-group/regular/"]
}

dependency "eks-cluster" {
  config_path = "../../eks-cluster"
  mock_outputs = {
    kubeconfig = <<EOT
"clusters":
- "cluster":
    "certificate-authority-data": "LS0tLS=="
    "server": "https://000000000000000000.aa1.region.eks.amazonaws.com"
  "name": "cam"
"users":
- "name": "cam"
  "user":
    "exec":
      "args":
      - "eks"
      - "get-token"
      - "--cluster-name"
      - "cam"
EOT
  }
}

inputs = {
  aws_region          = local.region_vars.locals.aws_region
  aws_profile         = local.account_vars.locals.aws_profile
  remote_state_bucket = local.account_vars.locals.remote_state_bucket
  environment         = local.env_vars.locals.env_name
  kubeconfig          = dependency.eks-cluster.outputs.kubeconfig
}



