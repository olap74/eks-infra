terraform {
  source = "../../../../../..//modules/eks-resources/external-dns"
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

dependency "environment" {
  config_path = "../../environment"
  mock_outputs = {
    domains = {
      "public" = "domain.cam"
      "root"   = "cluster.domain.cam"
    }
    zones = {
      "public" = "ZZZZZZZZZZZZZZZZZ"
      "root"   = "ZZZZZZZZZZZZZZZ"
    }
    metadata = {
      account     = "nonexistent"
      environment = "cluster-name"
      owner       = "someteam"
    }
  }
}

dependency "eks-cluster" {
  config_path = "../../eks-cluster"
  mock_outputs = {
    cluster = {
      oidc_provider_arn       = "arn:aws:iam::000000000000:oidc-provider/oidc.eks.region.amazonaws.com/id/111111111111111111111"
      cluster_oidc_issuer_url = "https://oidc.eks.region.amazonaws.com/id/111111111111111111111"
    }
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

  oidc_provider_arn       = dependency.eks-cluster.outputs.cluster.oidc_provider_arn
  cluster_oidc_issuer_url = dependency.eks-cluster.outputs.cluster.cluster_oidc_issuer_url
  env_metadata            = dependency.environment.outputs.metadata

  domains              = dependency.environment.outputs.domains
  zones                = dependency.environment.outputs.zones
  replicas             = local.env_vars.locals.eks-resources.external-dns.replicas
  extra_domain_filters = local.env_vars.locals.eks-resources.external-dns.extra_domain_filters
}



